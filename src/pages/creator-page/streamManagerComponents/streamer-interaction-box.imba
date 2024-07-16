import '../../../sharedComponents/video-player.imba'
# import '../../../code-editor.imba'
import '../../../sharedComponents/stackblitz-ide.imba'
import '../../../sharedComponents/yt-iframe.imba'
import './paint.imba'

import {nanoid} from 'nanoid'

# yt aspect-ration = 16:9
tag streamer-interaction-box

	# prop autorender = 60fps
	prop cameraStream
	prop screenShareStream
	prop windowStream
	prop cropTarget
	prop miniCamera = false
	prop cursorTimer
	prop answering
	prop reactions = []
	prop paintOpen
	prop width
	prop height
	prop display = {
		slide:false
	}
	prop onlyCamera
	prop content = null

	def showViewerSentiment(data)
		reactions.push(data)

	def awaken
		cropTarget = await CropTarget.fromElement($cropTarget)
		emit('cropWindow', cropTarget)

	# @autorun def resizeCamera
	# 	content ? (miniCamera = true) : (miniCamera = false)

	def disapearCursor
		document.body.style.cursor = "auto"
		clearTimeout(cursorTimer)
		cursorTimer = setTimeout(&,5000) do
			document.body.style.cursor = "none"

	def test
		console.log 'aaaaaa'
		console.log $pdf.contentWindow.document
		if $pdf.contentDocument
			console.log $pdf.contentDocument.getElementById('pageNumber').value

	css self 
			# w:100% 
			h:100%
			d:inline-block
			bg:var(--uibg)
			d:vflex jc:center ai:center
			# pl:12%
		.mainContainer h:90% bgc:black aspect-ratio: 16 / 9
		# @hover box-shadow:inset 0px 0px 0px 2px red
		# .yt pos:absolute l:50% x:-50% t:50% y:-50% w:calc((350 / 9)*16px) w:100% h:100% aspect-ratio:16 / 9
		.mediaContainer w:100% h:100%
		.screenShareVideo w:100% h:100%
		.questionContainer pos:absolute l:50% x:-50% t:5% min-width:50% max-width:90% d:vflex bgc:blue4
			.username fs:0.75rem
			.question as:center
			# w:560px h:315px
		.getWindowStreamBtt pos:absolute l:50% b:50% x:-50% y:-50%
			w:6rem h:3rem rd:6px bd:1px solid black
			d:flex ai:center jc:space-around
		.title
			h:15px 
			fs:0.7rem
			w:30%
			bg:var(--ui-container)
			pl:0.5rem
			ff:Poppins
			rd: 0.3rem 0.3rem 0rem 0rem
			# as:start
			# ml:12%
			

	def render
		<self
			@mousemove=disapearCursor
			@mouseout=clearTimeout(cursorTimer)
			[pos:relative]
		>
			if true
				<Overlay answering=answering>
			if paintOpen
				<paint [pos:absolute]>
			<div.title> 'Janela interativa'
			<div$cropTarget .mainContainer>
				# if !windowStream
				# 	<button.getWindowStreamBtt @click=emit('getWindowStream')> 'Compratilhar janela interativa'
				# else
				# if answering
				# 	<div$question .questionContainer>
				# 		<div.username> answering.username
				# 		<div.question> answering.txtPergunta

				# <div$reactions .reactions [w:100% h:100% pos:absolute]>
				# 	for reaction in reactions
				# 		<reaction-animation data=reaction>
				<div$container .mediaContainer>
					if screenShareStream
						<video .screenShareVideo srcObject=screenShareStream autoplay>
					# if onlyCamera
					# 	<video .screenShareVideo srcObject=cameraStream autoplay>
					else
						display.slide=false
						if content
							console.log content
							switch content.contentType
								when 'YT'
									# <iframe .yt src="{content.videoUrl}?start={content.startAt}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen>
									# <iframe [w:100% h:100%] src="https://www.youtube.com/embed/YFsaZAP-I64?si=tH1CwDKgb3uxRsO5&amp;start=24" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share">
									<iframe [w:100% h:100%] src="https://www.youtube.com/embed/{content.videoId};start={content.startAt}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share">
									# <iframe width="560" height="315" src="https://www.youtube.com/embed/JOJ5zihcd6Q?si=IxyyoGwebeXnKL_t&amp;start=43" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share">
									# <yt-iframe width=width streamer=true videoId=content.videoId startAt=content.startAt>
								when 'slide'
									display.slide=true
								when 'pdf'
									<iframe$pdf src=content.fileUrl [w:100% h:100%]>
								when 'codeEditor'
									# <code-editor receiver=false streamer=true>
									<stackblitz-ide streamer=true projectData=content.projectData>
								when 'website'
									<iframe$website src=content.websiteUrl [w:100% h:100%]>

							<iframe$slides [d:none]=!display.slide src=content.slideUrl [w:100% h:100%] frameborder="0" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true">
								
					# <camera-video cameraStream=cameraStream @resizeCamera=(miniCamera = !miniCamera) mini=miniCamera >

tag reaction-animation

	prop data

	def awaken
		self.style.left = "{Math.random() * 100}%"
		setTimeout(&, 2000) do
			imba.unmount(self)
		console.log self.style.left

	css self pos:absolute b:5% y:-50% r:0

	def render
		<self [o@off:0 y@in:100% ease:2s] ease>
			if data.sentimentType == 'love'
				<span .material-icons [c:red4]> 'favorite'
			if data.sentimentType == '?'
				<span .material-icons [c:yellow2]> 'help'


tag camera-video

	prop mini = false

	css self 
			w:60% as:center mx:auto bgc:cool4/70 ta:center pos:absolute rd:md
			@hover .resizeBtt d:block
		.cameraContainer pos:relative rd:md
		.camera w:100% rd:lg 
		.resizeBtt 
			pos:absolute b:0 y:-50% r:0 x:-50%
			bgc:cooler4/50 bd:none rd:md d:none cursor:pointer
			@hover bgc:cooler4/70
			@hover span o:1
		span c:white o:0.5 fs:30px

	@observable cameraStream
	@autorun def showCamera
		$camera.srcObject = cameraStream

	def build
		x = y = 0

	def render
		<self 
			[x:{x} y:{y}] 
			[w:200px r:0 b:0 cursor:grab @touch:grabbing]=mini
			[l:50% x:-50% t:50% y:-50% ]=!mini
			@touch.moved.sync(self)
		>  !cameraStream ? 'Camera desligada' : ''
			<div.cameraContainer>
				<video$camera .camera autoplay>
				<button .resizeBtt @click=emit('resizeCamera')>
					<span .material-icons> mini ? 'fit_screen' : 'photo_size_select_small'


tag Overlay

	prop answering
	prop canvasStream
	prop id
	prop mainCanvas
	prop context

	def createCanvas
		const options = {
			backgroundColor: null
		}
		html2canvas(self, options).then do(canvas)
			mainCanvas = canvas
			context = mainCanvas.getContext('2d')
			canvasStream = mainCanvas.captureStream()
			emit('canvasStream', canvasStream)

		# html2canvas($target, options).then do(canvas2)
		# 	canvas2.width=500
		# 	canvas2.height=500
		# 	context.drawImage(canvas2, 0, 0)

	
	css self h:100% w:100% pe:none zi:999999 pos:absolute bgc:none 
		.element pe:visible pos:absolute zi:999999
		.questionContainer pos:absolute l:50% x:-50% t:10% min-width:50% o:0.8 max-width:90% d:vflex bgc:var(--ui-container) pe:visible rd:5px
			.username fs:0.75rem pl:10px
			.question as:center

	def render
		<self>
			<div$question .questionContainer [d:none]=!answering>
				if answering
					<div.username> answering.username
					<div.question> answering.txtPergunta
		if answering
			if answering.docId !== id
				id = answering.docId
				createCanvas()