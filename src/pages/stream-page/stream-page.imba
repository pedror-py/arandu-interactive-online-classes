import { collection, doc, getDoc, getDocs, setDoc, addDoc, onSnapshot, query, where, updateDoc, serverTimestamp } from 'firebase/firestore'
import { auth, firestoreDB } from '../../firebase.imba'

import './streamComponents/stream-aux-sidebar.imba'
import './streamComponents/viewer-interaction-box.imba'
import './streamComponents/aux-sidebar-icons.imba'
import "./streamComponents/interaction-bar.imba"
import './streamComponents/quiz.imba'
# import './streamComponents/clip-video.imba'
import './streamComponents/sentiment-pannel.imba'
import '../../sharedComponents/video-player.imba'

import { socketConnect, joinRoom, newProducer, getProducersAndCheckConsumers, getRecvTransportList, signalNewConsumerTransport } from '../../mediasoup-client/socket-mediasoup-client.imba'
import { toggleSubscription } from '../../utils/toggleSubscription.imba'

let data = {
	pergunta: 'quem fez o q?'
	multi: false
	time: null
	respostas: [
		{
			letra:'a'
			respostaCorreta:false
			txtResposta: 'fulano'
		}
		{
			letra:'b'
			respostaCorreta:true
			txtResposta: 'o oto lá'
		}
		{
			letra:'c'
			respostaCorreta:false
			txtResposta: 'quem?'
		}
	]
}

tag stream-page

	prop user
	prop streamData = {
		streamId:''
		channelId:'blaaa'
		subscribed:false
		roomId:'8GRDOr0tM7wFhxacliPV'
		contentsData:[
			{
				contentType: 'camera'
			}
		]
		streamStates:{
			contentIndex: 0
		}
	}
	prop roomId
	prop streamDoc
	prop currentContent = {contentType:'YT'}
	prop showSidebar=false
	prop sidebarDisplay
	prop videoElement\HTMLVideoElement
	prop cameraElement\HTMLVideoElement
	prop txtSearch
	prop streamerSync
	prop splitScreen
	prop showCameraVideo = false
	prop streamStates = {
		chatOpen:true
		allowReactions:true
	}
	prop userDoc = null
	prop codeEditorChange
	prop iframeChange

	prop socket
	prop dataProducer

	prop medias = {
		camera: {
			consumers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		window: {
			consumers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		screenShare: {
			consumers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		merge: {
			consumers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
	}

	prop dataConsumer
	prop recvTransports

	prop cameraStream = new MediaStream()
	prop videoStream = new MediaStream()

	prop windowStream = new MediaStream()
	prop mergeStream = new MediaStream()
	# prop screenShareStream = new MediaStream()

	css d:flex jc:flex-end w:100% h:calc(100vh - var(--navbarHeigth))
		.toggleSidebar pos:absolute zi:2000 rd:lg size:40px 
			d:flex jc:center ai:center bd:none cursor:pointer
			bgc:clear @hover:gray4
			span fs:24px c:white
		main d:vflex w:100% h:100% pos:relative bgc:gray7
		pesquisinha mt:auto

	def mount
		socket = socketConnect()
		roomId = imba.router.path.split('/')[2]
		streamData.streamId = roomId
		streamDoc = doc(firestoreDB, "streams/{streamData.streamId}")
		# streamData.streamId = 'testing'
		console.log streamData.streamId
		listenStreamStates()
		enterStream()

	def unmount
		if socket
			socket.close()

	def enterStream()
		console.log 'enterStream'
		await joinRoom(roomId, streamer=false)
		# await createSendTransport(false)
		socket.on 'new-producer', do({producerId, appData}) # producerId is the remoteProducerId (server producer)
			console.log 'socket.on new-producer event'
			console.log 'producer appData sent from server producer:'
			console.log appData
			const dataChannel = false
			const consumer = await signalNewConsumerTransport(producerId, dataChannel, appData)
			console.log 'got new consumer'

		socket.on 'new-data-producer', do({producerId})
			console.log 'socket on new-data-producer event'
			const dataChannel = true
			const dataConsumer = await signalNewConsumerTransport(producerId, dataChannel)
			console.log dataConsumer
		dataProducer = await newProducer('data', null)
		console.log "dataProducer Id: {dataProducer.id}"
		await getMediaStreams()

	def getMediaStreams
		console.log 'getMediaStreams()'
		await getProducersAndCheckConsumers(false).then do()
			console.log 'finished getProducersAndCheckConsumers() function'

		setTimeout(&, 2000) do
			await updateConsumers()
			console.log 'finished consumers update'

	def updateConsumers
		console.log 'getting consumers'
		recvTransports = await getRecvTransportList()
		console.log "{recvTransports.length} - recvTransports"

		# get consumer from each recvTransport
		recvTransports.forEach do(transport)
			if transport.dataChannel
				if !dataConsumer
					dataConsumer = transport.dataConsumer
					console.log 'dataConsumer set'
					dataConsumer.on 'message', do(data)
						console.log "new message: {data}"
						data = JSON.parse(data)
						streamerEventHandler(data)
			else
				const consumer = transport.consumer

				# consumer was closed, setting local consumer to null
				# if consumer.closed
				# 	consumer = null

				if consumer.appData
					const {type, kind} = consumer.appData
					console.log '--------------------------'
					medias[type].consumers[kind] = consumer
					medias[type].tracks[kind] = consumer.track
					console.log type
					switch type
						when 'camera'
							cameraStream.addTrack(consumer.track)
							console.log 'ruuun'
						when 'window'
							windowStream.addTrack(consumer.track)
						when 'screenShare'
							windowStream.addTrack(consumer.track)
							# screenShareStream.addTrack(consumer.track)
						when 'merge'
							mergeStream.addTrack(consumer.track)
					console.log "added {type}, {kind} track"				

				videoElement.srcObject = showCameraVideo ? windowStream : mergeStream
				cameraElement.srcObject = cameraStream

	def streamerEventHandler(data)
		switch data.eventType
			when 'codeEditorChange'
				# $interaction-box.codeEditorChange=data
				console.log data
				codeEditorChange=data
				imba.commit()
				return

	def listenStreamStates
		onSnapshot(streamDoc, do(snapshot)
			console.log 'streamDoc change'
			const data = snapshot.data()
			if data.streamStates

				const contentIndex = data.streamStates.contentIndex

				streamData = {...streamData, ...data}
				streamStates = data.streamStates

				if streamStates.contentIndex != contentIndex
					contentUpdate(contentIndex)
				# if streamStates.streaming
				# 	getMediaStreams()
			else
				streamStates = {
					contentIndex:0
					chatOpen:true
					onlyCamera:true
				}

			imba.commit()
		)

	def toggleCameraStream
		showCameraVideo = !showCameraVideo
		console.log showCameraVideo
		if showCameraVideo
			cameraElement.srcObject = cameraStream
			# if streamStates.screenShare
			# 	videoElement.srcObject = screenShareStream
			# else
			# 	videoElement.srcObject = windowStream
			videoElement.srcObject = windowStream
			cameraElement.play()
		else
			videoElement.srcObject = mergeStream
			cameraElement.pause()
		videoElement.play()
		imba.commit()


	def contentUpdate(index)
		const contentsData = streamData.contentsData
		console.log contentsData
		currentContent = {
			contentType: contentsData[index].contentType
			contentData: contentsData[index].contentData
		}

	def handleQuizAnswer(e)
		const quizData = e.detail
		quizData.answeredBy = user.uid
		const quizCollection = collection(firestoreDB, "streams/{streamData.streamId}/quizes/{quizData.quizId}/answers")
		await addDoc(quizCollection, quizData)

	def newSearch(e)
		txtSearch = e.detail
		showSidebar = true
		sidebarDisplay = 'results'

	def sendSentiment e
		const sentimentType = e.detail
		const data = {
			eventType:'userSentiment'
			sentimentType
		}
		sendData(data)

	def sendData(data)
		if dataProducer
			console.log data
			let newData = JSON.stringify(data)
			dataProducer.send(newData)

	def checkSubscription
		if userDoc
			let userData = userDoc.data() 
			if userData.subscriptions
				if userData.subscriptions.includes(streamData.channelId)
					streamData.subscribed = true
				else
					streamData.subscribed = false

	def render
		# console.log consumers
		# console.log streamData
		checkSubscription()

		<self
			@click.ctrl=(console.log consumers; console.log streamData)
			@sendSentiment=sendSentiment
			@quizAnswered=handleQuizAnswer
		>
			if !showSidebar
				<button.toggleSidebar @click=(showSidebar=true)>
					<span .material-icons-outlined> 'chevron_left'
				# <aux-sidebar-icons 
				# 	chatOpen=streamStates.chatOpen
				# 	@openSidebar=(do
				# 		sidebarDisplay = e.detail
				# 		showSidebar = true
				# 	)
				# >
			<main>
				<viewer-interaction-box$interaction-box
					# contentType=currentContent.contentType
					contentType=streamData.contentsData[streamData.streamStates.contentIndex].contentType
					# contentsData=currentContent.contentData
					contentsData=streamData.contentsData[streamData.streamStates.contentIndex]
					streamerSync=streamerSync
					splitScreen=splitScreen
					streamData=streamData
					codeEditorChange=codeEditorChange
					iframeChange=iframeChange
					showCameraVideo=showCameraVideo
					onlyCamera=streamStates.onlyCamera
					@videoElement=(videoElement=e.detail)
					@cameraElement=(cameraElement=e.detail)
					@toggleSync=(streamerSync=e.detail)
					@toogleSplit=(splitScreen=e.detail)
					@toggleCameraStream=toggleCameraStream
					@enterStream=enterStream
					@newSearch=newSearch
					@toggleSubscription=toggleSubscription(user, userDoc, streamData.channelId)
				>

			<div.sideContent>
				<stream-aux-sidebar
					user=user
					streamDoc=streamDoc
					txtSearch=txtSearch
					bind:show=showSidebar
					display=sidebarDisplay
					chatOpen=data.chatOpen
					streamData=streamData
				>
			# <div [pos:absolute l:8%  t:15%]>
			# 	<quiz>
			# <paint route='/paint'>

			# <move-box >
			# <clip-video route='/streampage/clip'>


