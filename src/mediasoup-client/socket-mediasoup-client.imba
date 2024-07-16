import io from 'socket.io-client'
import * as mediasoupClient from 'mediasoup-client'
import mediasoupClientTypes from "mediasoup-client"

const roomName = 'testing'

const recvStream = new MediaStream()

let socket
let socketId
let device
let rtpCapabilities
let producerTransport # only need 1
let consumerTransports = []
# one consumer Transport for every consumer
# consumerTransports = [{
# 	consumerTransport
# 	serverConsumerTransportId
# 	consumer
# 	dataChannel
# }]
let consumingTransportsIdList = []

let params = {
	encodings: [
		{
			rid: 'r0',
			maxBitrate: 100000,
			scalabilityMode: 'S1T3',
		},
		{
			rid: 'r1',
			maxBitrate: 300000,
			scalabilityMode: 'S1T3',
		},
		{
			rid: 'r2',
			maxBitrate: 900000,
			scalabilityMode: 'S1T3',
		}
	],
	codecOptions: {
		videoGoogleStartBitrate: 1000
	}
}

let audioParams
let videoParams = { params }

export def socketConnect()

	let mediasoupUrl
	if process.env.NODE_ENV === 'development'
		mediasoupUrl = 'http://localhost:8080/mediasoup'
	if process.env.NODE_ENV === 'production'
		mediasoupUrl = 'http://34.95.157.7/mediasoup'

	socket = io(mediasoupUrl)
	socket.on 'connection-success', do({socketId})
		console.log "connection-success, socketId: {socketId}"
		socketId = socketId
	socket.on 'producer-closed', do({ remoteProducerId })
		console.log 'socket.on producer-closed event'
		# server notification is received when a producer is closed
		# we need to close the client-side consumer and associated transport
		const producerToClose = consumerTransports.find do(transportData)
			transportData.producerId === remoteProducerId
		if producerToClose
			producerToClose.consumerTransport.close()
			producerToClose.consumer.close()

		# remove the consumer transport from the list
		consumerTransports = consumerTransports.filter do(transportData)
			transportData.producerId !== remoteProducerId

	return socket

export def joinRoom(roomName, streamer)
	return new Promise do(resolve, reject)
		try
			# if streamer will create room
			socket.emit 'joinRoom', {roomName, streamer}, do(data)
				# console.log(`Router RTP Capabilities... ${data.rtpCapabilities}`)
				rtpCapabilities = data.rtpCapabilities
				device = await createDevice(streamer)
				await createSendTransport(streamer).then do
					resolve(producerTransport)
		catch e
			console.error("Error in joinRoom: ", e)
			reject(e)

def createDevice(streamer)
	try
		device = new mediasoupClient.Device()
		await device.load({
			routerRtpCapabilities: rtpCapabilities
		})
		console.log 'device created'
		# console.log('Device RTP Capabilities')
		return device
	
	catch e
		console.error("Error in createDevice: ", e)
		if e.name === 'UnsupportedError'
			console.warn('browser not supported')
		throw e  # Propagate the error

def createSendTransport(streamer)
	return new Promise do(resolve, reject)
		try
			socket.emit 'createWebRtcTransport', { isConsumer:false, streamer }, do({transportParams})
				console.log 'emit createWebRtcTransport SEND'
				# The server sends back params needed 
				# to create Send Transport on the client side
				if transportParams.error
					console.error("Transport creation error: ", transportParams.error)
					return
				# creates a new WebRTC Transport to send media
				# based on the server's producer transport params
				producerTransport = await device.createSendTransport(transportParams)

				producerTransport.on 'connect', do({dtlsParameters}, callback, errback)
					try
						# Signal local DTLS parameters to the server side transport
						await socket.emit( 'transport-connect', {dtlsParameters})

						callback()
					
					catch e
						errback(e)

				producerTransport.on 'produce', do(parameters, callback, errback)
					console.log 'producerTransport.on produce event'
					try
						# tell the server to create a Producer
						# with the following parameters and produce
						# and expect back a server side producer id
						console.log parameters.appData
						socket.emit('transport-produce', {
							kind: parameters.kind
							rtpParameters: parameters.rtpParameters
							appData: parameters.appData
							streamer
						}, do({id, producersExist})
							# Tell the transport that parameters were transmitted and provide it with the server side producer's id.
							callback({ id })
						)

					catch e
						errback(e)

				producerTransport.on 'producedata', do(parameters, callback, errback)
					console.log 'producerTransport.on producedata'
					let {
						sctpStreamParameters,
						label,
						protocol,
						appData
						} = parameters

					try
						socket.emit 'transport-produce-data', { sctpStreamParameters, label, protocol, appData, streamer }, do({id})
							callback({ id })

					catch e
						errback(e)

				producerTransport.observer.on 'newproducer', do(producer)
					console.log "new {producer.kind} producer, producerTransport.observer.on 'newproducer'"

				resolve(producerTransport)
		catch e
			console.error("Error in createSendTransport: ", e)
			reject(e)

def connectSendTransport(type, track, appData=null)
	console.log 'connectSendTransport()'
	# we now call produce() to instruct the producer transport
	# to send media to the Router
	# params are mediasoup params + tracks
	try
		let producer

		if !appData
			appData = {}

		console.log "starting to produce, {type}"
		switch type
			when 'video'
				const params = { track, appData, ...videoParams, stopTracks:false }
				const videoProducer = await producerTransport.produce(params)
				producer = videoProducer
				console.log "video producer created, appData:"
				console.log producer.appData
			when 'audio'
				const params = { track, appData, ...audioParams, stopTracks:false }
				# audioParams = { track: stream.getAudioTracks()[0], ...audioParams }
				const audioProducer = await producerTransport.produce(params)
				producer = audioProducer
			when 'data'
				const dataProducerParams = {
					ordered        : false,
					maxRetransmits : 1,
					label          : 'chat',
					priority       : 'medium',
					appData        : { info: 'my-chat-DataProducer' }
				}
				const dataProducer = await producerTransport.produceData(dataProducerParams)

				dataProducer.on('error', do(error) console.log 'error: ', error)
				return dataProducer
		
		producer.on('trackended', do()
			console.log('track ended, closing producer')
			producer.close()
			# TODO: close audio track
		)

		producer.on('transportclose', do()
			console.log('transport ended, closing producer')
			producer.close()
		)

		return producer

	catch e
		console.error("Error in connectSendTransport: ", e)
		throw e


export def newProducer(type, track=null, appData=null)
	# user is informing it wants a new producer or data-producer
	return new Promise do(resolve, reject)
		try
			let producer = await connectSendTransport(type, track, appData)
			resolve(producer)
		catch e
			console.error("Error in newProducer: ", e)
			reject(e)

export def getProducersAndCheckConsumers(streamer)
	return new Promise do(resolve, reject)
		try
			await socket.emit 'getProducers', {streamer}, do({data})
				const producerIds = data.producerList
				const dataProducerIds = data.dataProducerList
				const producersAppData = data.producersAppData
				console.log "{producerIds.length} - producerIds"

				# for each of the producer create a consumer,the signalNewConsumerTransport() function will filter out already created consumers
				producerIds.forEach do(id)
					const appData = producersAppData[id]
					# let consumer = await signalNewConsumerTransport(id, false, appData) # dataChannel = false
					await signalNewConsumerTransport(id, false, appData) # dataChannel = false

				console.log "{dataProducerIds.length} - dataProducerIds"
				dataProducerIds.forEach do(id) 
					await signalNewConsumerTransport(id, true)
				resolve()
		catch e
			console.error("Error in getProducersAndCheckConsumers: ", e)
			reject(e)

export def signalNewConsumerTransport(remoteProducerId, dataChannel, appData=null)
	console.log 'signalNewConsumerTransport()'
	# a new producer from other user was detected, create respective local consumers
	return new Promise do(resolve, reject)
		try
			if consumingTransportsIdList.includes(remoteProducerId)
				resolve()
				return
			
			consumingTransportsIdList.push(remoteProducerId)
			console.log "consumingTransportsIdList.length: {consumingTransportsIdList.length}"

			await socket.emit 'createWebRtcTransport', {isConsumer:true, streamer}, do({transportParams})
				if transportParams.error
					console.log "transportParams.error: {transportParams.error}"
					resolve()
					return
				console.log 'created WebRtcTransport RECV'
				const serverConsumerTransportId = transportParams.id
				
				# create the recv transport and immediatly creates a consumer
				try
					const consumerTransport = device.createRecvTransport(transportParams)

				
					consumerTransport.on 'connect', do({dtlsParameters}, callback, errback)
						try
							await socket.emit 'transport-recv-connect', {
								dtlsParameters
								serverConsumerTransportId: transportParams.id
								appData
							}

							callback()
						
						catch e
							errback(e)

					consumerTransport.observer.on 'newconsumer', do(consumer)
						console.log "consumerTransport.observer.on 'newconsumer', appData: {consumer.appData}"

					consumerTransport.observer.on 'close', do()
						removeConsumerTransport(consumerTransport.id)

					const consumer = await connectRecvTransport(consumerTransport, remoteProducerId, transportParams.id, dataChannel, appData)

					resolve(consumer)

				catch e
					console.error("Error in consumerTransport: ", e)
					reject(e)
					return
		catch e
			console.error("Error in signalNewConsumerTransport: ", e)
			reject(e)

def connectRecvTransport(consumerTransport, remoteProducerId, serverConsumerTransportId, dataChannel, appData)
	return new Promise do(resolve, reject)
		try
			if dataChannel
				console.log "getting to consume data"
				const dataConsumer = await consumeData(consumerTransport, remoteProducerId, serverConsumerTransportId)
				resolve(dataConsumer)
			else
				# for consumer, we need to tell the server first
				console.log 'emit consume'
				await socket.emit 'consume', {
					rtpCapabilities: device.rtpCapabilities
					remoteProducerId
					serverConsumerTransportId
					streamer
					appData
				}, do({params})
					# console.log("Consumer Params {params}")
					if params.error
						console.log('Cannot Consume')
						reject(params.error)
						return
					
					const consumer = await consumerTransport.consume({
						id: params.id
						producerId: params.producerId
						kind: params.kind
						rtpParameters: params.rtpParameters
						appData: params.appData
					})
					console.log "consumer.appData:"
					console.log consumer.appData
					consumerTransports = [
						...consumerTransports,
						{
							consumerTransport
							serverConsumerTransportId
							consumer
							dataChannel
						}
					]

					consumer.on('transportclose', do
						console.log 'transport closed, closing consumer'
						consumer.close()
						removeConsumerTransport(consumerTransport.id)
					)

					consumer.on('trackended', do
						console.log 'track ended, closing consumer'
						consumer.close()
						consumerTransport.close()
						removeConsumerTransport(consumerTransport.id)
					)

					socket.emit('consumer-resume', { serverConsumerId: params.serverConsumerId })

					resolve(consumer)
		catch e
			console.error("Error in connectRecvTransport: ", e)
			reject(e)


def removeConsumerTransport(consumerTransportId)
	consumerTransports = consumerTransports.filter do(transportData)
		transportData.consumerTransport.id != consumerTransportId
	console.log "recvTransport removed"

export def getRecvTransportList
	return new Promise do(resolve, reject)
		resolve(consumerTransports)

def consumeData(consumerTransport, remoteProducerId, serverConsumerTransportId)
	# if dataConsumer
	# 	return
	return new Promise do(resolve, reject)
		console.log 'consume data1'
		socket.emit 'consume-data', { remoteProducerId, serverConsumerTransportId, streamer }, do({dataConsumerParams})
			const {
					id,
					dataProducerId,
					sctpStreamParameters
				} = dataConsumerParams

			const dataConsumer = await consumerTransport.consumeData({
				id
				dataProducerId
				sctpStreamParameters
			})

			consumerTransports = [
				...consumerTransports,
				{
					consumerTransport
					serverConsumerTransportId
					dataConsumer
					dataChannel:true
				}
			]

			dataConsumer.on('open', do()
				console.log 'dataConsumer open!'
			)

			dataConsumer.on('error', do(error)
				console.log 'dataConsumer error!: ', error
			)

			resolve(dataConsumer)
			return
