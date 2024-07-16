


tag test-recorder

	prop screenMedia
	prop cameraMedia
	prop combinedMedia
	prop recorder

	def start
		console.log 'hi'
		await window.navigator.mediaDevices.getDisplayMedia({video:true}).then do(media)
			screenMedia = media
			keepStreamActive(screenMedia)
			await window.navigator.mediaDevices.getUserMedia({audio: true, video: true}).then do(media2)
				cameraMedia = media2
				keepStreamActive(cameraMedia)

				screenMedia.width = window.screen.width
				screenMedia.height = window.screen.height
				screenMedia.fullcanvas = true
				console.log screenMedia.width, screenMedia.height
				cameraMedia.width = 320
				cameraMedia.height = 240
				# screenMedia.width = 640
				# screenMedia.height = 480
				cameraMedia.top = screenMedia.height - cameraMedia.height
				cameraMedia.left = screenMedia.width - cameraMedia.width
				record()
		
	def keepStreamActive(stream) 
		const video = document.createElement('video');
		video.muted = true
		video.srcObject = stream
		video.style.display = 'none'
		document.body.appendChild(video)

	def record
		const medias = [screenMedia, cameraMedia]
		const config = {
			type: 'video',
			mimeType: 'video/webm',
			previewStream: do(s)
				combinedMedia = s
				$video.muted = true
				$video.srcObject = s
		}
		recorder = new RecordRTC(medias, config)
		recorder.startRecording()

	def stopRecord
		recorder.stopRecording(do
			let blob = recorder.getBlob()
			$video.srcObject = null
			$video.src = URL.createObjectURL(blob)
			$video.muted = false
			)

	def test
		console.log cameraMedia.top
		cameraMedia.top = cameraMedia.top * 0.5
		console.log cameraMedia.top

	<self>
		console.log screenMedia
		console.log cameraMedia
		<video$video controls autoplay [ b:1px solid black w:40%]>
		<button @click=start> 'start'
		<button @click=stopRecord> 'stop'
		<button @click=test> 'change camera'