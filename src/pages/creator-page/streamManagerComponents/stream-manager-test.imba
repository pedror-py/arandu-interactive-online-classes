import { collection, doc, updateDoc, setDoc, onSnapshot, getDoc, query, orderBy, serverTimestamp} from 'firebase/firestore'
import { ref, uploadBytes } from 'firebase/storage'
import { VideoStreamMerger } from 'video-stream-merger'
import { nanoid } from 'nanoid'

import './stream-manager-timeline.imba'
import './stream-manager-dashboard.imba'
import './left-box.imba'
import './edit-stream-data.imba'
import './streamer-interaction-box.imba'
import './streamer-top-bar.imba'
import './stream-media-adder.imba'
import '../../stream-page/streamComponents/quiz.imba'

import { firestoreDB, storage } from '../../../firebase.imba'
import { socketConnect, joinRoom, createSendTransport, newProducer, signalNewConsumerTransport } from '../../../mediasoup-client/socket-mediasoup-client.imba'

# const videoUrl = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

const testContents = [
	# {
	# 	contentType: 'camera'
	# }
	{
		contentType:'pdf'
		fileUrl:'https://firebasestorage.googleapis.com/v0/b/free-educ-app.appspot.com/o/users%2FqC4ucvNb1sgARQ1UrMKFahmf16z1%2Fstreams%2F1%2Fcontent%2FpdfFiles%2Ff6O8PUf-rYWU1TENhXQCg.pdf?alt=media&token=8dd33f19-2287-412d-9cb1-dd36066a6872'
	}
	{
		contentType: 'quiz'
		pergunta:'quem fez o q?'
		quizId: nanoid()
		respostas:[
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
	{
		contentType: 'codeEditor'
	}
	{
		contentType: 'YT'
		videoUrl: "https://www.youtube.com/embed/Vst3GuXKAMQ"
		videoId:'M7lc1UVf-VE'
		startAt:65
	}
	{
		contentType: 'slide'
		slideUrl:"https://docs.google.com/presentation/d/e/2PACX-1vS2kvCGoVLzpkpkvZ7ij2ROdr9TFclUOXDwLUgC1sNIZn54sjgCAg5rGGuSxkscoXkEa_Pa_gm9kkHP/embed?start=false&loop=false&delayms=3000"
	}
]

# prop streamData = {
# 		type:'stream'
# 		streamed:false
# 		title:''
# 		tags:[]
# 		category:''
# 		dateTime:null
# 		contentsData: []  # lista de objetos com info de cada conteúdo
# 	}
const testData = {
	streamId:1
	title:''
	tags:[]
	category:''
	owner:'user'
	startedAt:''
	initialStates:{
		chatOpen:true
		allowReactions:true
	}
}

tag stream-manager-test

	prop windowStream\MediaStream = null
	prop cameraStream\MediaStream = null
	prop screenShareStream\MediaStream = null
	prop previewStream\MediaStream = null
	prop overlayStream = null

	prop tracks = {
		camera:{
			audio: null
			video: null
		}
		window:{
			audio: null
			video: null
		}
		screenShare:{
			audio: null
			video: null
		}
		merge:{
			audio: null
			video: null
		}
	}

	# prop dataChannel\RTCDataChannel
	prop cropTarget
	prop recorder
	prop streamTimeStamp = 0
	prop merger = new VideoStreamMerger({
		width: window.screen.width,   # Width of the output video
		height: window.screen.height,  # Height of the output video
		fps: 25,       # Video capture frames per second
		clearRect: true, # Clear the canvas every frame
		audioContext: null, # Supply an external AudioContext (for audio effects)
	})

	prop user
	prop streamsRef  # reference to collection of user streams (no stream data, only references)
	prop streamDoc
	prop streamId
	prop streamData = testData
	prop streamContents
	# prop streamContents = testContents

	# prop currentContentIndex = 0
	prop currentContentType
	prop popUp = ''
	prop paintOpen = false
	prop answering
	prop leftBoxDisplay
	prop streamStates = {
		contentIndex: 0
	}
	prop startTime
	prop cameraPosition = {x:0, y:0}
	prop onlyCamera = true

	prop producerTransport
	prop dataProducer
	prop dataConsumers = []
	prop producers = {
		camera: {
			audio: null
			video: null
		}
		window:{
			audio: null
			video: null
		}
		screenShare:{
			audio: null
			video: null
		}
		merge:{
			audio: null
			video: null
		}
	}
		
	prop medias = [
		{
			type: 'camera'
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		{
			type: 'window'
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		{
			type: 'screenShare'
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		{
			type: 'merge'
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
	]


	def mount
		suspend()
		streamId = imba.router.path.split('/')[-1]
		const docRef = doc(firestoreDB, "streams/{streamId}")
		streamDoc = await getDoc(docRef)
		streamData = streamDoc.data()
		streamStates = streamData.streamStates
		streamContents = streamData.streamContents
		listenToStreamDoc(streamDoc.ref)
		await setInitialStates().then do
			unsuspend()

	def unmount
		if socket
			socket.close()

	def listenToStreamDoc(ref)
		onSnapshot(ref, do(snapshot)
			streamData = snapshot.data()
			streamStates = streamData.streamStates
			streamContents = streamData.contentsData
			imba.commit()
		)

	# STREAM MANAGING ------------------------

	def newStream
	# TODO: nova stream vazia 

	def startStream()
		if streamStates.streaming
			finishStream()
		else
			socket = await socketConnect()

			await joinRoom(streamDoc.id, streamer=true).then do(dev)
				# device = dev
				producerTransport = await createSendTransport(true)

			socket.on 'new-producer', do({producerId})
				const dataChannel = false
				signalNewConsumerTransport(producerId, dataChannel)

			socket.on 'new-data-producer', do({producerId})
				console.log 'new data producer'
				console.log producerId
				const dataChannel = true
				const dataConsumer = await signalNewConsumerTransport(producerId, dataChannel)
				console.log dataConsumer
				dataConsumers.push(dataConsumer)
				listenToDataChannel(dataConsumer)

			# recordStream()
			dataProducer = await newProducer('data', null)
			streamData.streaming = true
			console.log streamData
			streamStates.streaming = true
			updateStates()
			streamData.startedAt = serverTimestamp()
			updateProducers()
			# updateStates()

	def recordStream()
		const medias = []
		cameraStream && medias.push(cameraStream)
		windowStream && medias.push(windowStream)
		screenShareStream && medias.push(screenShareStream)
		const config = {
			type: 'video',
			mimeType: 'video/webm',
			previewStream: do(s)
				previewStream = s
				# $preview.muted = true
				# $preview.srcObject = s
		}
		recorder = new MultiStreamRecorder(medias, config)
		recorder.record()
		startTime = new Date()
		streamData.startTime = startTime
		updateStates()
		# joinMedia(windowStream, cameraStream)
		# const medias = [windowStream, cameraStream, screenShareStream]
		# const medias = []

		# recorder = new RecordRTC(medias, config)
		# recorder.startRecording()
		# recorder = new MultiStreamRecorder(medias, options)

	def getCurrentRecordTime
		return 0
		# const recordedTime = new Date() - startTime
		# return recordedTime

	# def joinMedia(biggerMedia, smallMedia)
	# 	console.log biggerMedia.width
	# 	biggerMedia.width = window.screen.width
	# 	biggerMedia.height = window.screen.height
	# 	biggerMedia.fullcanvas = true
	# 	console.log biggerMedia.width, biggerMedia.height
	# 	smallMedia.width = 320
	# 	smallMedia.height = 240
	# 	# biggerMedia.width = 640
	# 	# biggerMedia.height = 480
	# 	smallMedia.top = biggerMedia.height - smallMedia.height
	# 	smallMedia.left = biggerMedia.width - smallMedia.width
	
	def mergeMedia(biggerMedia, smallMedia=null)
		merger.removeStream(biggerMedia)
		const streamOpts = {
			x: 0, # position of the top-left corner
			y: 0,
			width: merger.width,     # size to draw the stream
			height: merger.height,
			index: 0, # Layer on which to draw the stream (0 is bottom, 1 is above that, and so on)
			mute: false,  # if true, any audio tracks will not be merged
			draw: null,    # A custom drawing function (see below)
			audioEffect: null # A custom WebAudio effect (see below)
		}
		merger.addStream(biggerMedia, streamOpts)
		cameraPosition.x = merger.width - 320
		cameraPosition.y = merger.height - 240
		if smallMedia
			merger.removeStream(smallMedia)
			merger.addStream(smallMedia, {
				x: merger.width - 320
				y: merger.height - 240
				width: 320
				height: 240
				index: 1
				mute: false,
				draw: null,
				audioEffect: null
			})

	def uploadRecording
		const streamId = streamDoc.id
		# const blob = recorder.getBlob()
		# console.log blob
		# const storagePath = "streams/{streamId}.mp4"
		# const storageRef = ref(storage, storagePath)

		# await uploadBytes(storageRef, blob).then do
		# 	console.log 'file uploaded'
		# 	const data = {
		# 		streamed:true
		# 		storagePath
		# 	}
		# 	await setDoc(streamDoc.ref, data, {merge:true}).then do
		# 		const path = streamsRef.path + "/{streamId}"
		# 		await setDoc(doc(firestoreDB, path), data, {merge:true}).then do
		# 			console.log 'created ref at firestore'

	def openMedia
		if cameraStream
			cameraStream = removeStream(cameraStream, 'camera')
		else	
			cameraStream = await window.navigator.mediaDevices.getUserMedia({video:true, audio:true})

			cameraStream.getTracks().forEach do(track)
				tracks.camera[track.kind] = track
			addStream(cameraStream, 'camera')

	def getWindowStream
		if windowStream
			windowStream = removeStream(windowStream, 'window')
			fullCamera(true)
		else
			windowStream = await window.navigator.mediaDevices.getDisplayMedia({preferCurrentTab:true, audio:true})
			const [videoTrack] = windowStream.getVideoTracks()
			await videoTrack.cropTo(cropTarget)
			windowStream.getTracks().forEach do(track)
				tracks.window[track.kind] = track
			addStream(windowStream, 'window')
			fullCamera(false)

	def captureScreen(e)
		const screenSharing = e.detail
		if screenSharing
			screenShareStream = removeStream(screenShareStream, 'screenShare')
			streamStates.screenSharing = false
			fullCamera(true)
		else
			const displayMediaOptions = {video:{cursor: "always"}, audio:true}
			try
				screenShareStream = await window.navigator.mediaDevices.getDisplayMedia(displayMediaOptions)
				if screenShareStream
					streamStates.screenSharing = true
					screenShareStream.getTracks().forEach do(track)
						tracks.screenShare[track.kind] = track
					addStream(screenShareStream, 'screenShare')
					fullCamera(false)
			catch e
				console.log "Error: {e}"
		updateStates()

	def addStream(stream, type)
		merger.start()
		previewStream = merger.result
		tracks.merge.audio = previewStream.getAudioTracks()[0]
		tracks.merge.video = previewStream.getVideoTracks()[0]
		console.log 'adding stream'
		if recorder
			recorder.addStreams([stream])
		# only camera and window, and remove screenShare stream
		# if cameraStream && windowStream
		if type === 'window'
			tracks.window.video.enabled = true
			tracks.window.audio.enabled = true
			if screenShareStream
				screenShareStream = removeStream(screenShareStream, 'screenShare')
				streamStates.screenSharing = false
			# if cameraStream
			mergeMedia(windowStream, cameraStream)
				
		# only camera and screenShare and disable the window stream
		# if cameraStream && screenShareStream
		if type === 'screenShare'
			if windowStream
				tracks.window.video.enabled = false
				tracks.window.audio.enabled = false
			# if cameraStream
			mergeMedia(screenShareStream, cameraStream)
		if type === 'camera'
			if windowStream
				mergeMedia(windowStream, cameraStream)
			elif screenShareStream
				mergeMedia(screenShareStream, cameraStream)
			else
				fullCamera(true)

		updateProducers()
	
	def updateProducers
		# key: camera/window/screenShare
		# kind: audio/video
		if producerTransport
			for own key, value of producers 

				for own kind, producer of value
					# console.log key, value, kind, producer
					if !producer && tracks[key][kind]
						producers[key][kind] = await newProducer(kind, tracks[key][kind])
						# console.log producers[key][kind].track
						# console.log tracks[key][kind]
					# if producer && tracks[key][kind] == null
					# 	producer.close()
					# 	producer = null

			streamData.streamProducersIds = {
				cameraAudioId: producers.camera.audio ? producers.camera.audio.id : null
				cameraVideoId: producers.camera.video ? producers.camera.video.id : null
				windowAudioId: producers.window.audio ? producers.window.audio.id : null
				windowVideoId: producers.window.video ? producers.window.video.id : null
				screenAudioId: producers.screenShare.audio ? producers.screenShare.audio.id : null
				screenVideoId: producers.screenShare.video ? producers.screenShare.video.id : null
				mergeAudioId: producers.merge.audio ? producers.merge.audio.id : null
				mergeVideoId: producers.merge.video ? producers.merge.video.id : null
			}
			await updateStates()
			console.log dataProducer.id

	def removeStream(stream, type)
		stream.getTracks().forEach do(track)
			track.stop()
			for kind in ['audio', 'video']
				tracks[type][kind] = null
				if producers[type][kind]
					producers[type][kind].close()
					console.log producers[type][kind].closed
					producers[type][kind] = null
		merger.removeStream(stream)
		updateProducers()
		return null
		
	def listenToDataChannel(dataConsumer)
		console.log dataConsumer.dataProducerId
		dataConsumer.on 'message', do(data)
			console.log 'data'
			console.log data
			let newData = JSON.parse(data)
			viewerEventHandler(newData)

	def finishStream
		socket.disconnect()
		streamStates.streaming = false
		streamData.streaming = false
		# recorder.stopRecording(do() uploadRecording())
		try
			windowStream.getTracks().forEach do(track)
				track.stop()
			cameraStream.getTracks().forEach do(track)
				track.stop()
		streamData.endsAt = serverTimestamp()
		updateStates()

	def setInitialStates()
		streamStates = {
			chatOpen:true
			allowReactions:true
			screenSharing: Boolean(screenShareStream)
			contentIndex:0
			iframeStates: null
			onlyCamera
			streaming:false
		}
		streamData.streaming = false
		# streamData.contentsData = testContents # TODO: remove
		streamData.streamStates = streamStates
		streamData.streamProducersIds = {
			cameraAudioId: producers.camera.audio ? producers.camera.audio.id : null
			cameraVideoId: producers.camera.video ? producers.camera.video.id : null
			windowAudioId: producers.window.audio ? producers.window.audio.id : null
			windowVideoId: producers.window.video ? producers.window.video.id : null
			screenAudioId: producers.screenShare.audio ? producers.screenShare.audio.id : null
			screenVideoId: producers.screenShare.video ? producers.screenShare.video.id : null		
		}
		await updateStates()
		
	# CHANGES OF EVENTS AND STATES ------------------------
	
	def viewerEventHandler(newData)
		if (newData.eventType == 'userSentiment') && (streamStates.allowReactions)
			$interactionBox.showViewerSentiment(newData)

	def updateCameraPos(e)
		if e && e.detail.h
			cameraPosition.y += e.detail.h
			# cameraStream.left = cameraStream.left + e.detail.h
		if e && e.detail.v
			cameraPosition.x += e.detail.v
			# cameraStream.top = cameraStream.top + e.detail.v
		if cameraStream
			merger.removeStream(cameraStream)
			merger.addStream(cameraStream, {
				x: cameraPosition.x
				y: cameraPosition.y
				width: 320
				height: 240
				index: 1
				mute: false, 
				draw: null, 
				audioEffect: null
			})
	
	def fullCamera(full)
		onlyCamera = full
		# onlyCamera = !onlyCamera
		if cameraStream
			if onlyCamera
				const trackSettings = tracks.camera.video.getSettings()
				const width = merger.width * (trackSettings.height / trackSettings.width)
				merger.removeStream(cameraStream)
				merger.addStream(cameraStream, {
					x: (merger.width - width) / 2
					y: 0
					# width: merger.width
					width
					height: merger.height
					# height: trackSettings.height
					index: 1
					mute: false, 
					draw: null, 
					audioEffect: null
				})


				# try
				# 	tracks.window.video.enabled = false
				# 	tracks.window.audio.enabled = false
				# 	tracks.screenShare.video.enabled = false
				# 	tracks.screenShare.audio.enabled = false
				# catch
				for own type, kind of tracks
					if type === 'window' || type === 'screenShare'
						if tracks[type][kind]
							tracks[type][kind].enabled = false

			else
				for own type, kind of tracks
					if type === 'window' || type === 'screenShare'
						if tracks[type][kind]
							tracks[type][kind].enabled = true
				# try
				# 	tracks.window.video.enabled = true
				# 	tracks.window.audio.enabled = true
				# 	tracks.screenShare.video.enabled = true
				# 	tracks.screenShare.audio.enabled = true
				# catch
				updateCameraPos(null)
			if streamStates.onlyCamera !== onlyCamera
				streamStates.onlyCamera = onlyCamera
				updateStates()

	def contentChange(e)
		streamStates.contentIndex = e.detail
		currentContentType = streamContents[streamStates.contentIndex].contentType
		if currentContentType == 'quiz'
			leftBoxDisplay = 'quiz'
		updateStates()
		imba.commit()

	# def editorChange(e)
	# 	const change = e.detail
	# 	change.eventType = 'codeEditorChange'
	# 	sendData(change)
	
	def ideUpdate(e)
		const data = {
			eventType : 'codeEditorChange'
			projectData : e.detail
		}
		sendData(data)

	def iframeChange(e)
		const change = e.detail
		console.log e.detail
		sendData(change)

	def updateStreamData(e)
		let { title, tags } = e.detail
		streamData = {...streamData, title, tags}
		updateStates()
		popUp = null

	def addContent(e)
		const data = e.detail
		streamContents.splice(streamStates.contentIndex + 1, 0, data)
		popUp = null
		streamStates.contentIndex += 1
		currentContentType = streamContents[streamStates.contentIndex].contentType
		updateStates()

	def toggleChat
		streamStates.chatOpen = !streamStates.chatOpen
		updateStates()

	def toggleReactions
		streamStates.allowReactions = !streamStates.allowReactions
		updateStates()

	def startAnswer(e)
		answering = e.detail
		console.log answering
		answering.startedAt = getCurrentRecordTime()
		await updateDoc(answering.docRef, answering)
	
	def stopAnswer(e)
		const {contentsData, index} = e.detail
		contentsData.finishedAt = getCurrentRecordTime()
		merger.removeStream(overlayStream)
		await updateDoc(contentsData.docRef, contentsData)
		answering = false

	def updateStates()
		# TODO:
		await setDoc(streamDoc.ref, streamData, {merge:true}).then do()
			imba.commit()

	def sendData(data)
		if dataProducer
			console.log data
			let newData = JSON.stringify(data)
			dataProducer.send(newData)
		
	css self
			h:100% w:100% d:vflex
		.topSection 
			w:100% h:67%
			d:flex ai:flex-end
		.leftBox 
			h:100% bgc:cool5 w:16.5%
		.interactionBoxContainer 
			d:flex jc:center ai:center h:100%
		# video.preview flg:1
		.bottomSection d:flex h:28% w:100% bgc:cool7
		.timelineContainer h:100% w:10.5%
		.paintBtt h:35px rdb:10px bd:none ml:auto mr:auto
	
	def resize
		$leftBox.style.width = "{$bottomSection.offsetHeight * 16 / 9}px"
		let boxWidth = $interactionContainer.offsetHeight * 16 / 9
		$interactionContainer.style.width = "{boxWidth}px"
		let timelineWidth = "{window.innerWidth - $leftBox.offsetWidth - boxWidth}px"
		$timelineContainer.style.width = timelineWidth
		imba.commit()

	def render		
		<self
			@toggleChat=toggleChat
			@toggleReactions=toggleReactions
			@closePopUp=(popUp='')
			@shareLink=(popUp='shareLink')
			@newQuiz=(popUp='newQuiz')
			@updateStreamData=updateStreamData
			@togglePaint=(paintOpen=!paintOpen)
			@toggleCamera=(tracks.camera.video.enabled = !tracks.camera.video.enabled)
			@toggleAudio=(tracks.camera.audio.enabled = !tracks.camera.audio.enabled)
			@getWindowStream=getWindowStream
			@onlyCamera=(do() fullCamera(!onlyCamera))
			@canvasStream=(overlayStream=e.detail; merger.addStream(overlayStream))
			@addMedia=(popUp='addMedia')
			@addContent=addContent
			@editStreamData=(popUp='editStreamData')
			@resize.log('resized')=resize
		>
			# console.log window.screen.width
			# console.log window.screen.height
			# <div [pos:absolute w:1910px h:10px bgc:emerald4]>
			<streamer-top-bar user=user live=streamStates.streaming streamData=streamData>
			<div$topSection  .topSection>
				<div$leftBox .leftBox>
					<left-box user=user 
						streamId=streamId
						streamStates=streamData.streamStates 
						display=leftBoxDisplay
						streamData=streamData
						@answering=startAnswer
						@stopAnswer=stopAnswer
					>
				<div$interactionContainer .interactionBoxContainer>
					<streamer-interaction-box$interactionBox
						width=$interactionContainer.offsetWidth
						height=$interactionContainer.offsetHeight
						cameraStream=cameraStream
						windowStream=windowStream 
						content=(streamContents ? streamContents[streamStates.contentIndex] : null)
						screenShareStream=screenShareStream
						answering=answering
						paintOpen=paintOpen
						onlyCamera=onlyCamera
						@cropWindow=(cropTarget=e.detail)
						# @editorChange=editorChange
						@ideUpdate=ideUpdate
						@iframeChange=iframeChange
					>
				# <video.preview controls autoplay=true srcObject=localStream>
				<div$timelineContainer .timelineContainer>
					<stream-manager-timeline 
						contentsData=streamContents
						@contentChange=contentChange
					>
			<div$bottomSection .bottomSection>
				<TransmissionPreview
				cameraStream=cameraStream
				windowStream=windowStream
				screenShareStream=screenShareStream
				previewStream=previewStream
				cameraVideoTrack=tracks.camera.video
				cameraAudioTrack=tracks.camera.audio
				merger=merger
				cameraPosition=cameraPosition
				@updateCameraPos=updateCameraPos
				>
				if paintOpen
					<canvas-tools @clearCanvas>
				else
					<button.paintBtt @click=(paintOpen = !paintOpen)> 'Desenhar por cima'
				<stream-manager-dashboard
					chatOpen=streamStates.chatOpen
					allowReactions=streamStates.allowReactions
					streaming=streamStates.streaming
					screenSharing=streamStates.screenSharing
					windowSharing=(windowStream ? true : false)
					cameraStream=(cameraStream ? true : false)
					onlyCamera=onlyCamera
					@startStream=startStream
					@openMedia=openMedia
					@screenShare=captureScreen
					@answer=(leftBoxDisplay='questions')
				>
				# <button @click=viewerEventHandler({eventType:'userSentiment', sentimentType:'?'})> 'react'
				# <button @click=(dataProducer.send('helooo'))> 'test send data'
			if popUp
				if tracks.window.video
					tracks.window.video.enabled = false
				<PopUp popUp=popUp streamId=streamId bind=streamData user=user>
			else
				if tracks.window.video
					tracks.window.video.enabled = true

tag TransmissionPreview

	@observable display = 'preview'
	@observable cameraStream
	# @observable windowStream
	# @observable screenShareStream
	@observable previewStream
	prop cameraVideoTrack
	prop cameraAudioTrack
	prop videoEnabled
	prop audioEnabled
	prop cameraPosition
	prop merger

	@autorun def togglePreview()
		if display === 'camera' && cameraStream
			$preview.srcObject = cameraStream
		if display === 'preview' && previewStream
			$preview.srcObject = previewStream

	css self h:100% mr:auto
		.container d:flex h:100%
		.controls d:vflex w:60px jc:space-evenly
		.videoAudio d:flex jc:space-evenly
		.preview h:100%
		.previewVideo h:100% bgc:black
		.toggleBtt rd:50% s:30px bd:none p:none
		.material-icons-outlined fs:18px
		.cameraPos d:vflex ai:center
			button s:20px rd:50% bd:none

	def render
		$preview.style.width = "{$preview.offsetHeight * 16 / 9}px"
		if cameraStream
			videoEnabled = cameraVideoTrack.enabled
			audioEnabled = cameraAudioTrack.enabled
		<self>
			<div.container>
				<div.preview>
					<video$preview .previewVideo controls muted>
				<div.controls>
					<div.videoAudio>
						<button.toggleBtt [bgc:rose4]=!videoEnabled
						@click=emit('toggleCamera')
						disabled=!cameraStream
						> 
							<span .material-icons-outlined> videoEnabled ? 'videocam' : 'videocam_off'
						<button.toggleBtt [bgc:rose4]=!audioEnabled
						@click=emit('toggleAudio')
						disabled=!cameraStream
						>
							<span .material-icons-outlined> audioEnabled ? 'mic' : 'mic_off'
					<button @click=(display='camera') disabled=!cameraStream> 'câmera'
					<button @click=(display='preview') disabled=!previewStream> 'preview'
					<div.cameraPos>
						<button @click=emit('updateCameraPos', {h: -10})> '^'
						<div [d:flex g:10px]>
							<button @click=emit('updateCameraPos', {v: -10})> '<'
							<button @click=emit('updateCameraPos', {v: 10})> '>'
						<button @click=emit('updateCameraPos', {h: 10})> 'v'

tag PopUp

	prop user
	prop data
	prop streamId
	prop popUp = ''

	css self 
		.popUpBackground h:100vh w:100vw pos:absolute bgc:hsla(0,0%,0%,0.7) zi:1000 l:50% x:-50% t:50% y:-50%
		.popUp bgc:blue2 rd:20px shadow:xl bd:blue5
			pos:absolute l:50% x:-50% t:50% y:-50%
		.quizMaker size:400px
		.editStream size:500px h:80vh
		stream-media-adder w:80vw h:80vh

	<self>
		<div.popUpBackground>
			<div.popUp>
				<global  @pointerdown.outside=emit('closePopUp')>
				if popUp === 'editStreamData'
					<div.editStream>
						let editData = (do({title, tags, category}) {title, tags, category})(data)
						<edit-stream-data bind=editData>
				if popUp === 'newQuiz'
					<div.quizMaker> 
						<quiz-maker>
				if popUp === 'shareLink'
					<share-stream streamId=streamId>
				if popUp === 'addMedia'
					<stream-media-adder streamData=data user=user>

tag share-stream

	prop link
	prop streamId
	prop copied = false

	def unmount
		copied=false

	def copy
		window.navigator.clipboard.writeText(link)
		copied = true

	css self w:500px h:120px
		.text pl:20px
		input w:80% p:10px m:10px
		button h:50px py:10px
		.copied ml:80%


	def render
		link = "http://{window.location.href.split('/')[2]}/stream/{streamId}"
		<self>
			console.log window.location.href
			<div.text> 'Link para compartilhar a trasmissão'
			<input bind=link value=link readOnly>
			<button @click=copy>
				<span .material-symbols-outlined> 'content_copy'
			if copied
				<div.copied > 'Copiado!'
