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

import cam from '../../../assets/icons/cam-icon.svg'
import preview from '../../../assets/icons/preview-icon.svg'
import copyIcon from '../../../assets/icons/copy-icon.svg'

import { firestoreDB, storage } from '../../../firebase.imba'
import { socketConnect, joinRoom, newProducer, signalNewConsumerTransport } from '../../../mediasoup-client/socket-mediasoup-client.imba'
import { transcriptionApi } from '../../../APIs/transcription-api.js'

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

tag stream-manager

	prop windowStream\MediaStream = null
	prop cameraStream\MediaStream = null
	prop screenShareStream\MediaStream = null
	prop previewStream\MediaStream = null
	prop overlayStream = null

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
	prop bitrateSum = ''

	prop producerTransport
	prop dataProducer
	prop dataConsumers = []
		
	prop medias = {
		camera: {
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		window: {
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		screenShare: {
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
		merge: {
			producers: {
				audio: null
				video: null
			}
			tracks: {
				audio: null
				video: null
			}
		}
	}

	def mount
		suspend()
		streamId = imba.router.path.split('/')[-1]
		const docRef = doc(firestoreDB, "streams/{streamId}")
		streamDoc = await getDoc(docRef)
		streamData = streamDoc.data()
		console.log streamData
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
		let intervalId
		if streamStates.streaming
			finishStream()
			clearInterval(intervalId)
		else
			socket = await socketConnect()

			producerTransport = await joinRoom(streamDoc.id, streamer=true)

			socket.on 'new-producer', do({producerId, appData}) # producerId is the remoteProducerId (server producer)
				console.log "socket.on new-producer"
				const dataChannel = false
				signalNewConsumerTransport(producerId, dataChannel, appData)

			socket.on 'new-data-producer', do({producerId})
				console.log 'new data producer'
				console.log producerId
				const dataChannel = true
				const dataConsumer = await signalNewConsumerTransport(producerId, dataChannel)
				dataConsumers.push(dataConsumer)
				listenToDataChannel(dataConsumer)
			
			intervalId = getBitrate()
			console.log 'dfghjkdfghjk'
			console.log intervalId
			# recordStream()
			console.log "creatig data producer"
			dataProducer = await newProducer('data', null)
			streamData.streaming = true
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

	def enableDisableTrack(types=[], kinds=[], enabled\Boolean)
		for type in types
			for kind in kinds
				if medias[type].tracks[kind]
					medias[type].tracks[kind].enabled = enabled
					
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

	def openMedia(type)
		console.log 'open Media'
		if cameraStream
			if medias.camera.tracks[type]
				medias.camera.tracks[type].enabled = !medias.camera.tracks[type].enabled
				return

			else
				let tempStream
				tempStream = await window.navigator.mediaDevices.getUserMedia({"{type}": true})
				tempStream.getTracks().forEach do(track)
					cameraStream.addTrack(track)
					medias.camera.tracks[type] = track
		else
			# cameraStream = await window.navigator.mediaDevices.getUserMedia({"{type}": true})
			cameraStream = await window.navigator.mediaDevices.getUserMedia({video:true, audio:true})

			speechTranscription(cameraStream)

		cameraStream.getTracks().forEach do(track)
			medias.camera.tracks[track.kind] = track
			track.onended = do()
				cameraStream = removeStream(cameraStream, 'camera')

		addStream(cameraStream, 'camera')

	def speechTranscription(stream)
		const audioTracks = stream.getAudioTracks()
		if audioTracks.length > 0
			const audioStream = new MediaStream(audioTracks)
			let mediaRecorder = new MediaRecorder(audioStream);
			mediaRecorder.ondataavailable = do(event)
				const timestamp = new Date().toISOString();
				const audioBlob = event.data;
				transcriptionApi(audioBlob, timestamp)
			mediaRecorder.start(5000)

	def getWindowStream
		if windowStream
			windowStream = removeStream(windowStream, 'window')
			fullCamera(true)
		else
			windowStream = await window.navigator.mediaDevices.getDisplayMedia({preferCurrentTab:true, audio:true})
			const [videoTrack] = windowStream.getVideoTracks()
			await videoTrack.cropTo(cropTarget)
			windowStream.getTracks().forEach do(track)
				medias.window.tracks[track.kind] = track
				track.onended = do()
					windowStream = removeStream(windowStream, 'window')
			addStream(windowStream, 'window')
			fullCamera(false)

	def captureScreen(e)
		# const screenSharing = e.detail
		if streamStates.screenSharing
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
						medias.screenShare.tracks[track.kind] = track
						track.onended = do()
							screenShareStream = removeStream(screenShareStream, 'screenShare')
					addStream(screenShareStream, 'screenShare')
					fullCamera(false)
			catch e
				console.log "Error: {e}"
				streamStates.screenSharing = false
				screenShareStream = false
		updateStates()

	def addStream(stream, type)

		console.log "adding stream, {type}"
		if recorder
			recorder.addStreams([stream])

		# only camera and window, and remove screenShare stream
		# if cameraStream && windowStream
		if type === 'window'
			# enableDisableTrack(types=['window'], ['audio', 'video'], true)
			if screenShareStream
				screenShareStream = removeStream(screenShareStream, 'screenShare')

			enableDisableTrack(types=['window'], ['audio', 'video'], true)
			streamStates.screenSharing = false
			# if cameraStream

			# replace window producer track for window track if they are different
			for kind in ['audio', 'video']
				if medias.window.producers[kind]
					if medias.window.producers[kind].track.id !== medias.window.tracks[kind].id
						const track = medias.window.tracks[kind]
						await medias.window.producers[kind].replaceTrack({track}).then do
							console.log 'window producer replaced with window track'
							medias.window.producers[kind].resume()

					enableDisableTrack(types=['window'], ['audio', 'video'], true)
			mergeMedia(windowStream, cameraStream)
		# only camera and screenShare and disable the window stream
		# if cameraStream && screenShareStream
		# replace window producer track for screenShare track if they are different
		if type === 'screenShare'

			streamStates.screenSharing = true

			for kind in ['audio', 'video']
				# use window producer if it exists
				if medias.window.producers[kind]
					enableDisableTrack(types=['window'], ['audio', 'video'], false)
					if medias.window.producers[kind].track.id !== medias.screenShare.tracks[kind].id
						const track = medias.screenShare.tracks[kind]
						await medias.window.producers[kind].replaceTrack({track}).then do
							console.log 'window producer replaced with screenShare track'
							console.log "track id: {track.id}"
							medias.window.producers[kind].resume()
							mergeMedia(screenShareStream, cameraStream)
					return
			mergeMedia(screenShareStream, cameraStream)
				
		if type === 'camera'
			if windowStream
				mergeMedia(windowStream, cameraStream)
			elif screenShareStream
				mergeMedia(screenShareStream, cameraStream)
			else
				fullCamera(true)

		merger.start()
		previewStream = merger.result
		medias.merge.tracks.audio = previewStream.getAudioTracks()[0]
		medias.merge.tracks.video = previewStream.getVideoTracks()[0]

		updateProducers()

	def updateProducers
		# key: camera/window/screenShare
		# kind: audio/video
		if producerTransport
			console.log 'updating producers'
			for own key, media of medias
				for kind of ['audio', 'video']
					const appData = {type:key, kind}

					# have track but not producer --> create new producer for the track, exept for screenShare
					if !media.producers[kind] && media.tracks[kind]

						if key === 'screenShare' && streamStates.screenSharing
							if !medias.window.producers[kind]
								console.log "creating new window producer for 'screenShare', {kind}"
								medias.window.producers[kind] = await newProducer(kind, medias.screenShare.tracks[kind], appData)

						else
							console.log "creating new producer, {key}, {kind}"
							media.producers[kind] = await newProducer(kind, media.tracks[kind], appData)

					# have producer but not track --> close producer
					if media.producers[kind] && !media.tracks[kind]
						console.log "closing producer, {key}, {kind}"
						media.producers[kind].close()
						media.producers[kind] = null
						# TODO: close serverside producer

			await updateStates()

	def removeStream(stream, type)

		stream.getTracks().forEach do(track)
			const kind = track.kind
			medias[type].tracks[kind] = null
			if medias[type].producers[kind]
				medias[type].producer[kind].close()
				console.log "closing producer, {type}, {kind}"
				medias[type].producers[kind] = null
			track.stop()

		if type === 'screenShare'
			enableDisableTrack(types=['window'], ['audio', 'video'], true)
			streamStates.screenSharing = false
		
		merger.removeStream(stream)

		updateProducers()
		return null
		
	def listenToDataChannel(dataConsumer)
		console.log dataConsumer.dataProducerId
		dataConsumer.on 'message', do(data)
			console.log "new message via data channel: {data}"
			const newData = JSON.parse(data)
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

		await updateStates()
		
	def getBitrate
		# if streamStates.streaming
		let previousStats = {}
		const intervalId = setInterval(&, 1000) do
			console.log 'run'
			let sum = 0
			for own media, value of medias
				for own type, producer of value.producers
					if producer
						try
							const statsReport = await producer.getStats()
							# if statsReport && statsReport.length > 0
							statsReport.forEach do(report)
								if (report.type === 'outbound-rtp')

									if (previousStats[report.id])
										const previous = previousStats[report.id]
										const bytesDifference = report.bytesSent - previous.bytesSent
										# Convert milliseconds to seconds
										const timeDifferenceInSeconds = (report.timestamp - previous.timestamp) / 1000

										if (timeDifferenceInSeconds > 0)
											# Calculate bitrate in bits per second
											const bitrate = (((bytesDifference * 8) / timeDifferenceInSeconds) / 1000).toFixed(1) 
											console.log("Current Bitrate for {media}, {type}: {bitrate} Kbps");
											sum += parseFloat(bitrate);
									previousStats[report.id] = {
										bytesSent: report.bytesSent,
										timestamp: report.timestamp
									}
						catch e
							console.error e

			bitrateSum = sum
			bitrateSum = bitrateSum.toFixed(0)
			console.log bitrateSum
			imba.commit()

		return intervalId

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
				const trackSettings = medias.camera.tracks.video.getSettings()
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

				enableDisableTrack(['window', 'screenShare'], ['audio', 'video'], false)

			else
				enableDisableTrack(['window', 'screenShare'], ['audio', 'video'], true)
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

	def editorChange(e)
		const change = e.detail
		change.eventType = 'codeEditorChange'
		sendData(change)

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

	def record
		socket.emit('start-recording')
		
	css self
			d:vflex
			w:100%
			h:100%
			bg:black
		.mainContainer
			w:100%
			h:calc(100% - 2rem)
			d:flex
			.left
				d:vflex
				h:100%
				w:calc(100% * (20 / 90))
				bg:green
			.center
				d:vflex
				h:100%
				w:calc(100% * (54 / 90))
				bg:blue
				.interactionBoxContainer
					w:100% h:75%
			.right
				h:100%
				d:vflex
				w:calc(100% * (16 / 90))
				bg:yellow
		.container

	def render
		if windowStream
			if popUp
				medias.window.tracks.video.enabled = false
			else
				medias.window.tracks.video.enabled = true

		<self
			@toggleChat=toggleChat
			@toggleReactions=toggleReactions
			@closePopUp=(popUp='')
			@closeModal=(popUp='')
			@shareLink=(popUp='shareLink')
			@newQuiz=(popUp='newQuiz')
			@updateStreamData=updateStreamData
			@togglePaint=(paintOpen=!paintOpen)
			@toggleCamera=(medias.camera.tracks.video.enabled = !medias.camera.tracks.video.enabled)
			@toggleAudio=(medias.camera.tracks.audio.enabled = !medias.camera.tracks.audio.enabled)
			@getWindowStream=getWindowStream
			@onlyCamera=(do() fullCamera(!onlyCamera))
			@canvasStream=(overlayStream=e.detail; merger.addStream(overlayStream))
			@addMedia=(popUp='addMedia')
			@addContent=addContent
			@editStreamData=(popUp='editStreamData')
			@startStream=startStream
			@record=record

			@toggleMic=openMedia('audio')
			@toggleWebcam=openMedia('video')
		>
			<streamer-top-bar user=user live=streamStates.streaming streamData=streamData bitrateSum=bitrateSum>
			<div.mainContainer>
				<div.left>
					<left-box 
						user=user 
						streamId=streamId
						# streamStates=streamData.streamStates 
						display=leftBoxDisplay
						streamData=streamData
						@answering=startAnswer
						@stopAnswer=stopAnswer
					>
					<TransmissionPreview
						cameraStream=cameraStream
						windowStream=windowStream
						screenShareStream=screenShareStream
						previewStream=previewStream
						cameraVideoTrack=medias.camera.tracks.video
						cameraAudioTrack=medias.camera.tracks.audio
						merger=merger
						cameraPosition=cameraPosition
						@updateCameraPos=updateCameraPos					
					>
				<div.center>
					<div$interactionContainer .interactionBoxContainer>
						<streamer-interaction-box
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
							@editorChange=editorChange
							@iframeChange=iframeChange
						>
					# <div.container>
					<stream-manager-dashboard
						chatOpen=streamStates.chatOpen
						allowReactions=streamStates.allowReactions
						streaming=streamStates.streaming
						screenSharing=streamStates.screenSharing
						windowSharing=(windowStream ? true : false)
						cameraStream=(cameraStream ? true : false)
						camOpen=(medias.camera.tracks.video ? medias.camera.tracks.video.enabled : false)
						micOpen=(medias.camera.tracks.audio ? medias.camera.tracks.audio.enabled : false)
						onlyCamera=onlyCamera
						paintOpen=paintOpen
						@screenShare=captureScreen
	# 				@answer=(leftBoxDisplay='questions')					
					>
				<div.right>
					<stream-manager-timeline
						contentsData=streamContents
						streamer=true
	 					@contentChange=contentChange
					>
					
			if paintOpen
				<canvas-tools [pos:absolute]>

			switch popUp
				when 'editStreamData'
					let editData = (do({title, tags, category}) {title, tags, category})(streamData)
					<edit-stream-data bind=editData>
				when 'newQuiz'
					<quiz-maker>
				when 'shareLink'
					<share-stream streamId=streamId>
				when 'addMedia'
					# <stream-media-adder streamData=streamData user=user>
					<add-content-pannel>


tag TransmissionPreview

	@observable display = 'camera'
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
		$preview.play()

	css self
			pos:relative
			w:100%
			h:30%
			d:vflex
			jc:space-between
			# ai:flex-end
			flex-shrink: 0
			bg:var(--ui-container)
		.controls
			pos:absolute
			t:0
			w:100%
			h:25px
			display: flex;
			# box-sizing: border-box
			# padding: 0.5rem 0.975rem 0.85rem 1rem;
			justify-content: center;
			align-items: center;
			gap: 2rem;
			# background: linear-gradient(180deg, rgba(0, 0, 0, 0.45) 0%, rgba(0, 0, 0, 0.00) 100%);
			.button
				s:25px
				d:flex ai:center jc:center
				background: rgba(23, 23, 23, 0.60)
				border-radius: 0.2rem;
				o:0.4
				&.selected
					o:1
			svg
				s:20px
				fill:#ffffff
		.preview
			d:vflex
			# w:100%
			h:100%
			aspect-ratio: 16 / 9
			# bg:grey
			video
				pos:relative
				bg:black
				w:100%
				h:100%
				aspect-ratio: 16 / 9
			
	def render
		<self>
			<div.preview>
				<video$preview autoplay controls muted>
			<div.controls>
				<div.button .selected=(display=='camera') @click=(display='camera') description='blaa'>
					<svg src=cam>
				<div.button .selected=(display=='preview') @click=(display='preview')>
					<svg src=preview>
				# <div> 'expand'

	# css self
	# 		h:100% w:100% d:vflex
	# 	.topSection 
	# 		w:100% h:67%
	# 		d:flex ai:flex-end
	# 	.leftBox 
	# 		h:100% bgc:cool5 w:16.5%
	# 	.interactionBoxContainer 
	# 		d:flex jc:center ai:center h:100%
	# 	# video.preview flg:1
	# 	.bottomSection d:flex h:28% w:100% bgc:cool7
	# 	.timelineContainer h:100% w:10.5%
	# 	.paintBtt h:35px rdb:10px bd:none ml:auto mr:auto
	

	# def render		
	# 	<self
	# 		@toggleChat=toggleChat
	# 		@toggleReactions=toggleReactions
	# 		@closePopUp=(popUp='')
	# 		@shareLink=(popUp='shareLink')
	# 		@newQuiz=(popUp='newQuiz')
	# 		@updateStreamData=updateStreamData
	# 		@togglePaint=(paintOpen=!paintOpen)
	# 		@toggleCamera=(medias.camera.tracks.video.enabled = !medias.camera.tracks.video.enabled)
	# 		@toggleAudio=(medias.camera.tracks.audio.enabled = !medias.camera.tracks.audio.enabled)
	# 		@getWindowStream=getWindowStream
	# 		@onlyCamera=(do() fullCamera(!onlyCamera))
	# 		@canvasStream=(overlayStream=e.detail; merger.addStream(overlayStream))
	# 		@addMedia=(popUp='addMedia')
	# 		@addContent=addContent
	# 		@editStreamData=(popUp='editStreamData')
	# 		@resize.log('resized')=resize
	# 	>
	# 		# console.log window.screen.width
	# 		# console.log window.screen.height
	# 		# <div [pos:absolute w:1910px h:10px bgc:emerald4]>
	# 		<streamer-top-bar user=user live=streamStates.streaming streamData=streamData>
	# 		<div$topSection  .topSection>
	# 			<div$leftBox .leftBox>
	# 				<left-box user=user 
	# 					streamId=streamId
	# 					streamStates=streamData.streamStates 
	# 					display=leftBoxDisplay
	# 					streamData=streamData
	# 					@answering=startAnswer
	# 					@stopAnswer=stopAnswer
	# 				>
	# 			<div$interactionContainer .interactionBoxContainer>
	# 				<streamer-interaction-box$interactionBox
	# 					width=$interactionContainer.offsetWidth
	# 					height=$interactionContainer.offsetHeight
	# 					cameraStream=cameraStream
	# 					windowStream=windowStream 
	# 					content=(streamContents ? streamContents[streamStates.contentIndex] : null)
	# 					screenShareStream=screenShareStream
	# 					answering=answering
	# 					paintOpen=paintOpen
	# 					onlyCamera=onlyCamera
	# 					@cropWindow=(cropTarget=e.detail)
	# 					@editorChange=editorChange
	# 					@iframeChange=iframeChange
	# 				>
	# 			# <video.preview controls autoplay=true srcObject=localStream>
	# 			<div$timelineContainer .timelineContainer>
	# 				<stream-manager-timeline 
	# 					contentsData=streamContents
	# 					@contentChange=contentChange
	# 				>
	# 		<div$bottomSection .bottomSection>
	# 			<TransmissionPreview
	# 			cameraStream=cameraStream
	# 			windowStream=windowStream
	# 			screenShareStream=screenShareStream
	# 			previewStream=previewStream
	# 			cameraVideoTrack=medias.camera.tracks.video
	# 			cameraAudioTrack=medias.camera.tracks.audio
	# 			merger=merger
	# 			cameraPosition=cameraPosition
	# 			@updateCameraPos=updateCameraPos
	# 			>
	# 			if paintOpen
	# 				<canvas-tools @clearCanvas>
	# 			else
	# 				<button.paintBtt @click=(paintOpen = !paintOpen)> 'Desenhar por cima'
	# 			<stream-manager-dashboard
	# 				chatOpen=streamStates.chatOpen
	# 				allowReactions=streamStates.allowReactions
	# 				streaming=streamStates.streaming
	# 				screenSharing=streamStates.screenSharing
	# 				windowSharing=(windowStream ? true : false)
	# 				cameraStream=(cameraStream ? true : false)
	# 				onlyCamera=onlyCamera
	# 				@startStream=startStream
	# 				@openMedia=openMedia
	# 				@screenShare=captureScreen
	# 				@answer=(leftBoxDisplay='questions')
	# 			>
	# 			# <button @click=viewerEventHandler({eventType:'userSentiment', sentimentType:'?'})> 'react'
	# 			# <button @click=(dataProducer.send('helooo'))> 'test send data'
	# 		if popUp
	# 			# do enableDisableTrack(['window'], ['video'], false)
	# 			<PopUp popUp=popUp streamId=streamId bind=streamData user=user>
	# 		# else
	# 		# 	do enableDisableTrack(['window'], ['video'], true)


# tag TransmissionPreview

# 	@observable display = 'preview'
# 	@observable cameraStream
# 	# @observable windowStream
# 	# @observable screenShareStream
# 	@observable previewStream
# 	prop cameraVideoTrack
# 	prop cameraAudioTrack
# 	prop videoEnabled
# 	prop audioEnabled
# 	prop cameraPosition
# 	prop merger

# 	@autorun def togglePreview()
# 		if display === 'camera' && cameraStream
# 			$preview.srcObject = cameraStream
# 		if display === 'preview' && previewStream
# 			$preview.srcObject = previewStream

# 	css self h:100% mr:auto
# 		.container d:flex h:100%
# 		.controls d:vflex w:60px jc:space-evenly
# 		.videoAudio d:flex jc:space-evenly
# 		.preview h:100%
# 		.previewVideo h:100% bgc:black
# 		.toggleBtt rd:50% s:30px bd:none p:none
# 		.material-icons-outlined fs:18px
# 		.cameraPos d:vflex ai:center
# 			button s:20px rd:50% bd:none

# 	def render
# 		$preview.style.width = "{$preview.offsetHeight * 16 / 9}px"
# 		if cameraStream
# 			videoEnabled = cameraVideoTrack.enabled
# 			audioEnabled = cameraAudioTrack.enabled
# 		<self>
# 			<div.container>
# 				<div.preview>
# 					<video$preview .previewVideo controls muted>
# 				<div.controls>
# 					<div.videoAudio>
# 						<button.toggleBtt [bgc:rose4]=!videoEnabled
# 						@click=emit('toggleCamera')
# 						disabled=!cameraStream
# 						> 
# 							<span .material-icons-outlined> videoEnabled ? 'videocam' : 'videocam_off'
# 						<button.toggleBtt [bgc:rose4]=!audioEnabled
# 						@click=emit('toggleAudio')
# 						disabled=!cameraStream
# 						>
# 							<span .material-icons-outlined> audioEnabled ? 'mic' : 'mic_off'
# 					<button @click=(display='camera') disabled=!cameraStream> 'câmera'
# 					<button @click=(display='preview') disabled=!previewStream> 'preview'
# 					<div.cameraPos>
# 						<button @click=emit('updateCameraPos', {h: -10})> '^'
# 						<div [d:flex g:10px]>
# 							<button @click=emit('updateCameraPos', {v: -10})> '<'
# 							<button @click=emit('updateCameraPos', {v: 10})> '>'
# 						<button @click=emit('updateCameraPos', {h: 10})> 'v'

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

tag share-stream < modal

	prop link
	prop streamId
	prop copied = false

	def unmount
		copied=false

	def copy
		window.navigator.clipboard.writeText(link)
		copied = true

	css self
		.container
			bg:var(--ui-container)
			w:40% h:6rem
			rd:1rem
			ff:Poppins
		.text pl:10px mt:5px fs:0.8rem
		.box
			d:flex ai:center 
		input 
			w:80% p:10px  m:5px 10px 0 10px
			rd:0.5rem bd:none
		.button 
			d:flex ai:center jc:center
		svg
			fill:#ffffff
			o:0.4
			&.copied
				fill:#5EB137
				o:1
		.copiedText
			fs:0.8rem
			c:#5EB137
			ml:10px
			mt:5px


	def render
		link = "http://{window.location.href.split('/')[2]}/stream/{streamId}"
		<self @click.self=emit('closePopUp')>
			<div.container>
				<div.text> 'Link para compartilhar a trasmissão'
				<div.box>
					<input bind=link value=link readOnly>
					<div.button @click=copy>
						<svg .copied=copied src=copyIcon>
				if copied
					<div.copiedText > 'Copiado!'
