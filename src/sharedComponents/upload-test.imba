import { storage } from "../firebase.imba"

tag upload-test

	prop recorder\MediaRecorder
	prop blob\Blob
	prop recording = false


	def getMedia
		return await window.navigator.mediaDevices.getUserMedia({video:true})



	def record
		recording = !recording
		if recording
			let device = getMedia()
			let items = []
			device.then do(stream)
				recorder = new MediaRecorder(stream)
				$video.srcObject = stream
		
				recorder.ondataavailable = do(e)
					console.log e.data.size, e.data.type

					items.push(e.data)
					if recorder.state == 'inactive'
						blob = new Blob(items, {type:'video/mp4'})
						# $mainAudio.src = "{URL.createObjectURL(blob)}"
						
				recorder.start(2000)

	<self>
		<video$video controls>
		<button @click=record> 'start'
