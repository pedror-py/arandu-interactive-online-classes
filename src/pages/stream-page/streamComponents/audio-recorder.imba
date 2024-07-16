

tag audio-recorder

	prop recorder\MediaRecorder
	prop device
	prop speechRecognition
	prop recognition
	prop blob\Blob
	prop recording = false
	prop transcript
	prop showTranscript = false

	css self h:100%
		.container d:vflex ai:center g:10px h:100%
		audio w:240px
		.recordBtt bgc:cool4 rd:50% size:100px cursor:pointer mt:10%
		.saveBtt mt:auto mb:5% rd:md shadow:lg
		.closeBtt pos:absolute t:8px r:8px rd:50% bd:none mt:2px size:30px
			bgc:red3/85 @hover:red4

	def mount
		

		try
			speechRecognition = window.webkitSpeechRecognition
			recognition = new speechRecognition()
		catch e
			console.error(e)
			$('.no-browser-support').show();

		if speechRecognition
			recognition.onstart = do()
				console.log('Voice recognition activated. Try speaking into the microphone.')	
			recognition.onspeechend = do()
				console.log('You were quiet for a while so voice recognition turned itself off.')
			recognition.onerror = do(event)
				if(event.error == 'no-speech')
					console.log('No speech was detected. Try again.')
			recognition.onresult = do(event)
				let current = event.resultIndex
				transcript = event.results[current][0].transcript
		
	def recordAudio
		await window.navigator.mediaDevices.getUserMedia({audio:true}).then do(stream)
			# device=dev
			console.log stream	
			let items = []
			# device.then do(stream)
			recorder = new MediaRecorder(stream)
			recorder.ondataavailable = do(e)
				items.push(e.data)
				if recorder.state == 'inactive'
					blob = new Blob(items, {type:'audio/webm'})
					$mainAudio.src = "{URL.createObjectURL(blob)}"

			recorder.onstart = do
				recognition.start()
			recorder.onstop = do
				recognition.stop()
			recording = !recording
			if recording
				recorder.start()
			else
				recorder.stop()
				recording = false
				stream.getTracks().forEach do(track)
					track.close()

	def saveAudio
		emit('newAudio', blob)
		closeRecorder()

	def closeRecorder
		recording = false
		recorder = null
		emit('closeRecorder')

	<self>
		<div.container>
			<button.recordBtt @click=recordAudio>
				if recording
					<span .material-icons-outlined [fs:60px c:emerald4] > 'mic'
				else
					<span .material-icons-outlined [fs:60px] > 'mic_none'
			<p> "gravando audio..." if recording
			if !recording && recorder
				<audio$mainAudio controls>
				<div [d:flex]>
					<button.saveBtt @click=saveAudio> 'Salvar'
					<button.saveBtt @click=(showTranscript=true)> 'Transcrever'
				if showTranscript
					<div> transcript


		<button.closeBtt @click=closeRecorder> 'x'