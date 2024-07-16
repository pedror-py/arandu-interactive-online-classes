import * as mediasoup from "mediasoup"

// # const roomName = 'testing'

let worker

let rooms = {}
// # { roomName1: { Router, owner:socketId1, rooms: [ socketId1, ... ] }, ...}

let peers = {}
// # { socketId1: { roomName1, socket, transports = [id1, id2,] }, producers = [id1, id2,] }, consumers = [id1, id2,], peerDetails, streamer }, ...}

let transports = []
// # [ { socketId1, roomName1, transport, consumer, streamer }, ... ]

let producers = []
// # [ { socketId1, roomName1, producer, streamer}, ... ]

let dataProducers = []
// # [ { socketId1, roomName1, dataProducer, streamer}, ... ]

let consumers = []
// # [ { socketId1, roomName1, consumer, streamer}, ... ]

let dataConsumers = []
// # [ { socketId1, roomName1, dataConsumer, streamer}, ... ]

const mediaCodecs = [
	{
		kind: 'audio',
		mimeType: 'audio/opus',
		clockRate: 48000,
		channels: 2,
	},
	{
		kind: 'video',
		mimeType: 'video/VP8',
		clockRate: 90000,
		parameters: {
			'x-google-start-bitrate': 1000
		}
	}
]

async function createWorker() {
    worker = await mediasoup.createWorker({
        rtcMinPort: 2000,
        rtcMaxPort: 2020
    });
    console.log(`worker pid ${worker.pid}`);

    worker.on('died', () => {
        console.error('ERROR: mediasoup worker has died');
        setTimeout(() => process.exit(1), 2000); // exit in 2 seconds
    });
}

createWorker()

export function mediasoupServer(io) {
    const connections = io.of('/mediasoup');

    connections.on('connection', (socket) => {
        socket.emit('connection-success', { socketId: socket.id });

        function removeItems(items, socketId, type) {
            items.forEach(item => {
                if (item.socketId === socket.id && item[type]) {
                    item[type].close();
                }
            });
            return items.filter(item => item.socketId !== socket.id);
        }
        
        socket.on('disconnect', () => {
            console.log('peer disconnected');
            if (peers[socket.id]) {
                const { roomName } = peers[socket.id];
                delete peers[socket.id];
                
                // remove socket from room
                if (rooms[roomName]) {
                    rooms[roomName].peers = rooms[roomName].peers.filter(socketId => socketId !== socket.id);
                }
            }
            
            // clean up
            consumers = removeItems(consumers, socket.id, 'consumer');
            dataConsumers = removeItems(dataConsumers, socket.id, 'dataConsumer');
            producers = removeItems(producers, socket.id, 'producer');
            dataProducers = removeItems(dataProducers, socket.id, 'dataProducer');
            transports = removeItems(transports, socket.id, 'transport');
            console.log("socket.on disconnect, user transports closed and removed");
        });
             
            
        socket.on('joinRoom', async ({ roomName, streamer }, callback) => {
            try {
                peers[socket.id] = {
                    socket: socket,
                    roomName: roomName,
                    transports: [],
                    producers: [],
                    dataProducers: [],
                    consumers: [],
                    dataConsumers: [],
                    peerDetails: {
                        name: '',
                        isAdmin: false
                    }
                };

                // create Router if it does not exist
                let router1 = await createRoom(roomName, socket.id, streamer);
                const rtpCapabilities = router1.rtpCapabilities;
                callback({ rtpCapabilities });
            } catch (e) {
                console.log(`Error: ${e}`);
            }
        });        
        

        socket.on('createWebRtcTransport', async ({ isConsumer, streamer }, callback) => {
            try {
                const roomName = peers[socket.id].roomName;
                const router = rooms[roomName].router;
        
                const transport = await createWebRtcTransport(router);
                addTransport(transport, roomName, isConsumer, socket.id, streamer);
        
                callback({
                    transportParams: {
                        id: transport.id,
                        iceParameters: transport.iceParameters,
                        iceCandidates: transport.iceCandidates,
                        dtlsParameters: transport.dtlsParameters,
                        sctpParameters: transport.sctpParameters
                    }
                });
            } catch (e) {
                console.log(`Error: ${e}`);
            }
        });


        socket.on('getProducers', ({ streamer }, callback) => {
            try {
              const { roomName } = peers[socket.id];
              let producerList = [];
              let producersAppData = {};
              let dataProducerList = [];
              
              producers.forEach((producerData) => {
                  if (producerData.socketId !== socket.id && producerData.roomName === roomName) {
                  producerList = [...producerList, producerData.producer.id];
                  producersAppData[producerData.producer.id] = producerData.producer.appData;
                }
            });
            
            dataProducers.forEach((producerData) => {
                if (producerData.socketId !== socket.id && producerData.roomName === roomName) {
                    dataProducerList = [...dataProducerList, producerData.dataProducer.id];
                }
            });
            
            // Return the producer list back to the client
            const data = { producerList, dataProducerList, producersAppData };
            callback({ data });
            } catch (e) {
                console.log(`Error: ${e}`);
            }
        });
          

        socket.on('transport-connect', ({ dtlsParameters }) => {
        // console.log('DTLS PARAMS... ', { dtlsParameters });
        getTransport(socket.id).connect({ dtlsParameters });
        });
          

        socket.on('transport-produce', async ({ kind, rtpParameters, appData, streamer }, callback) => {
            try {
              const producerTransport = getTransport(socket.id);
              const producer = await producerTransport.produce({
                  kind,
                rtpParameters,
                appData,
            });
            console.log('server producer.appData');
            console.log(producer.appData);
            
            // Add producer to the producers array
            const { roomName } = peers[socket.id];
            addProducer(producer, roomName, socket.id, streamer);
            informConsumers(roomName, socket.id, producer.id, false, streamer, appData);
            // console.log('Producer ID: ', producer.id);
            
            producer.on('transportclose', () => {
                console.log('transport for this producer closed');
                producer.close();
            });
            
            // Send back to the client the Producer's id
            callback({
                id: producer.id,
                producersExist: producers.length > 1 ? true : false,
            });
        } catch (e) {
            console.log(`Error: ${e}`);
        }
        });
        
		
        socket.on('transport-produce-data', async ({ sctpStreamParameters, label, protocol, appData, streamer }, callback) => {
            try {
              const producerTransport = getTransport(socket.id);
              
              const dataProducer = await producerTransport.produceData({
                  sctpStreamParameters,
                  label,
                  protocol,
                  appData,
                });
                
                // Add dataProducer to the producers array
                const { roomName } = peers[socket.id];
                addDataProducer(dataProducer, roomName, socket.id, streamer);
                
                informConsumers(roomName, socket.id, dataProducer.id, true, streamer, appData);
              // console.log('DataProducer ID: ', dataProducer.id);
              
              dataProducer.on('transportclose', () => {
                  console.log('transport for this dataProducer closed');
                  dataProducer.close();
                });
                
                // Send back to the client the Producer's id
                callback({ id: dataProducer.id });
            } catch (e) {
                console.log(`Error: ${e}`);
            }
        });
          

        socket.on('transport-recv-connect', async ({ dtlsParameters, serverConsumerTransportId, appData }) => {
            try {
              // console.log("DTLS PARAMS: {dtlsParameters}");
              const transportData = transports.find((data) => data.isConsumer && data.transport.id == serverConsumerTransportId);
              const consumerTransport = transportData.transport;
              await consumerTransport.connect({ dtlsParameters });
            } catch (e) {
              console.log(`Error: ${e}`);
            }
        });
        

        socket.on('consume', async ({ rtpCapabilities, remoteProducerId, serverConsumerTransportId, streamer, appData }, callback) => {
            try {
                const { roomName } = peers[socket.id];
                const router = rooms[roomName].router;
                const transportData = transports.find((data) => data.isConsumer && data.transport.id == serverConsumerTransportId);
                let consumerTransport = transportData.transport;
                
                // Check if the router can consume the specified producer
                if (router.canConsume({
                producerId: remoteProducerId,
                rtpCapabilities,
              })) {
                // console.log 'can consume'
                // Transport can now consume and return a consumer
                const consumer = await consumerTransport.consume({
                  producerId: remoteProducerId,
                  rtpCapabilities,
                  paused: true,
                  appData,
                });
          
                console.log("server consumer.appData:");
                console.log(consumer.appData);
                
                consumer.on('transportclose', () => {
                  console.log('transport close from consumer');
                });
          
                consumer.on('producerclose', () => {
                  console.log('producer of consumer closed');
                  socket.emit('producer-closed', { remoteProducerId });
                  
                  consumerTransport.close([]);
                  transports = transports.filter((transportData) => transportData.transport.id !== consumerTransport.id);
                  consumer.close();
                  consumers = consumers.filter((consumerData) => consumerData.consumer.id !== consumer.id);
                });
          
                addConsumer(consumer, roomName, socket.id, streamer);
                
                // Extract the following params from the consumer to send back to the Client
                const params = {
                    id: consumer.id,
                  producerId: remoteProducerId,
                  kind: consumer.kind,
                  rtpParameters: consumer.rtpParameters,
                  serverConsumerId: consumer.id,
                  appData: consumer.appData,
                };
                
                callback({ params });
            }
            } catch (e) {
              console.log(`Error: ${e.message}`);
              callback({
                params: {
                    error: e,
                },
            });
            }
        });
          

        socket.on('consume-data', async ({ remoteProducerId, serverConsumerTransportId }, callback) => {
            try {
              const { roomName } = peers[socket.id];
              const router = rooms[roomName].router;
              const transportData = transports.find((data) => data.isConsumer && data.transport.id == serverConsumerTransportId);
              let consumerTransport = transportData.transport;
              const dataProducerId = remoteProducerId;
              const dataConsumer = await consumerTransport.consumeData({ dataProducerId });
              
              dataConsumer.on('message', (message, ppid) => {
                  console.log("text message received:", message);
                });
                
                const dataConsumerParams = {
                id: dataConsumer.id,
                dataProducerId,
                sctpStreamParameters: {
                    maxRetransmits: 1,
                    ordered: false,
                    // maxPacketLifeTime: '',
                    streamId: 0,
                },
            };
              callback({ dataConsumerParams });
            } catch (e) {
              console.log(`Error: ${e}`);
            }
        });
        
        
        socket.on('consumer-resume', ({ serverConsumerId }) => {
            // console.log('consumer resume');
            const consumerData = consumers.find((data) => data.consumer.id === serverConsumerId);
            // console.log(consumerData);
            const consumer = consumerData.consumer;
            
            consumer.resume();
        });
          
    })
}
        
        
async function createRoom(roomName, socketId, streamer) {
    try {
        let router1;
        let peers = [];
        let owner;
    
        if (rooms[roomName]) {
        router1 = rooms[roomName].router;
        peers = rooms[roomName].peers || [];
        } else {
            router1 = await worker.createRouter({ mediaCodecs });
        }
    
    console.log(`peers.length:${peers.length}`, `Router ID: ${router1.id}`);
    rooms[roomName] = {
        router: router1,
        peers: [...peers, socketId],
    };
    
    if (streamer) {
        rooms[roomName].owner = socketId;
    }
    
        return router1;
    } catch (e) {
        console.log(`Error: ${e}`);
    }
}
          

function createWebRtcTransport(router) {
    return new Promise(async (resolve, reject) => {
      try {
        const webRtcTransportOptions = {
          listenIps: [
            {
              ip: '0.0.0.0',
              announcedIp: '127.0.0.1',
            },
          ],
          enableUdp: true,
          enableTcp: true,
          preferUdp: true,
          enableSctp: true,
        };
  
        let transport = await router.createWebRtcTransport(webRtcTransportOptions);
        // console.log(`transport id: ${transport.id}`);
  
        transport.on('dtlsstatechange', (dtlsState) => {
          if (dtlsState === 'closed') {
            transport.close();
          }
        });
  
        transport.on('close', () => {
          console.log('transport closed');
        });
  
        resolve(transport);
      } catch (e) {
        reject(e);
      }
    });
}
  

function informConsumers(roomName, socketId, id, dataChannel, streamer, appData) {
    try {
      console.log("A new producer just joined, let all consumers consume this producer");
  
      // A new producer just joined, let all consumers consume this producer
  
      if (!dataChannel) {
        producers.forEach((producerData) => {
          if (producerData.socketId !== socketId && producerData.roomName === roomName) {
            const producerSocket = peers[producerData.socketId].socket;
            // Use socket to send producer id to producer
            producerSocket.emit('new-producer', { producerId: id, appData: producerData.appData });
            // Producer or dataProducer ID
          }
        });
      } else {
        dataProducers.forEach((dataProducerData) => {
          if (dataProducerData.socketId !== socketId && dataProducerData.roomName === roomName) {
            if (streamer) {
              const producerSocket = peers[dataProducerData.socketId].socket;
              // Use socket to send producer id to producer
              producerSocket.emit('new-data-producer', { producerId: id });
            } else {
              if (dataProducerData.streamer) {
                const streamerSocket = peers[dataProducerData.socketId].socket;
                streamerSocket.emit('new-data-producer', { producerId: id });
              }
            }
          }
        });
      }
    } catch (e) {
      console.log(`Error: ${e}`);
    }
}
  
function getTransport(socketId) {
    const producerTransport = transports.find((transport) => transport.socketId === socketId && !transport.isConsumer);
    return producerTransport ? producerTransport.transport : null;
}
  
function addTransport(transport, roomName, isConsumer, socketId, streamer) {
    transports = [
      ...transports,
      { socketId, transport, roomName, isConsumer, streamer },
    ];
  
    peers[socketId] = {
      ...peers[socketId],
      transports: [...peers[socketId].transports, transport.id],
    };
}
  
function addProducer(producer, roomName, socketId, streamer) {
    producers = [
      ...producers,
      { socketId, producer, roomName, streamer },
    ];
  
    peers[socketId] = {
      ...peers[socketId],
      producers: [...peers[socketId].producers, producer.id],
    };
}
  
function addDataProducer(dataProducer, roomName, socketId, streamer) {
    dataProducers = [
      ...dataProducers,
      { socketId, dataProducer, roomName, streamer },
    ];
  
    peers[socketId] = {
      ...peers[socketId],
      dataProducers: [...peers[socketId].dataProducers, dataProducer.id],
    };
}
  
function addConsumer(consumer, roomName, socketId, streamer) {
    consumers = [
      ...consumers,
      { socketId, consumer, roomName, streamer },
    ];
  
    peers[socketId] = {
      ...peers[socketId],
      consumers: [...peers[socketId].consumers, consumer.id],
    };
  }
  
function addDataConsumer(dataConsumer, roomName, socketId) {
    dataConsumers = [
      ...dataConsumers,
      { socketId, dataConsumer, roomName },
    ];
  
    peers[socketId] = {
      ...peers[socketId],
      dataConsumers: [...peers[socketId].dataConsumers, dataConsumer.id],
    };
}
  