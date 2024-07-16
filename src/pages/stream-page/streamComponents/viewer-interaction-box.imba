import './quiz.imba'
# import '../../../code-editor.imba'
import '../../../sharedComponents/stackblitz-ide.imba'
import '../../../sharedComponents/yt-iframe.imba'

tag viewer-interaction-box

	prop contentType
	prop contentsData
	prop windowStream
	prop cameraStream
	prop streamerSync=true
	prop splitScreen=false
	prop streamData
	prop showCameraVideo
	prop onlyCamera
	prop barFocus = false

	@observable codeEditorChange
	@observable iframeChange
	@autorun def reRender
		imba.commit()

	def awaken
		emit('cameraElement', $camera)

	css self w:100% h:100%
		.mainContainer 
			w:calc(100% - 62px) l:62px h:100% pos:relative d:vflex
			background:#E58320 jc:center
			.mediasContainer w:100% d:flex
				.playerContainer w:100% h:100%
				.contentContainer w:50% aspect-ratio: 16 / 9
		# .contentContainer pos:absolute w:100% h:100% max-width:1000px 
		# .cameraVideo pos:absolute b:0 r:0 h:25%
		# .yt pos:absolute l:0 b:0 w:95% h:95% aspect-ratio:16/9 bd:none
		.popBtt ml:75%
		# .mediasContainer h:100% w:100% d:flex
		.splitLeft
			d:vflex w:50% 
			animation: slideLeft 1s forwards
		.center
			animation: centerElement 1s forwards
		.splitRight
		iframe bd:none
		.description as:flex-start t:50px l:50px font-family:Sen fs:1.2rem animation:none


		@keyframes slideLeft 
			0%
				width: 100%
				# transform: translateX(0)
			100%
				width: 50%
				# transform: translateX(-100%)
		@keyframes slideRight 
			0%
				width: 0%
			100%
				width: 50%
		@keyframes centerElement 
			0%
				width: 50%
			100%
				width: 100%


	def render
		console.log contentsData
		if onlyCamera
			showCameraVideo=false

		<self>
			<div.mainContainer
				[background: linear-gradient(to left, #660E37 40%,  #E58320 60%)]=splitScreen
			>
				# <div [d:flex] 
				# # [d:none]=onlyCamera
				# >
				# if !onlyCamera
				if cameraStream
					<button.popBtt 
					@click=emit('toggleCameraStream')
					> showCameraVideo ? 'Merge camera' : 'Pop camera' 
				
				# <button.splitBtt 
				# @click=emit('toogleSplit', !splitScreen)
				# > splitScreen ? 'Apenas video stream' : 'Acessar conteúdo' 
					
				<div$container .mediasContainer [h:100%]=!splitScreen>


				
					# <div.playerContainer [w:100%] [w:50%]=splitScreen>
					<div.playerContainer .splitLeft=splitScreen .center=!splitScreen>
						<div.description [l:550px]> 'Transmissão' if splitScreen
						<video-player [w:100% h:90%] controls=true autoplay=true showTime=false streamData=streamData 
						showCameraVideo=showCameraVideo splitScreen=splitScreen interactionBarElement=$interaction-bar
						barFocus=barFocus
						>

					if splitScreen
						# <div .contentContainer [d:block w:50%]>
						<div .contentContainer 
						# [d:block w:50%]=splitScreen .splitRight=splitScreen 
						[x@in:-100% x@out:-100%] ease>
							<div.description> 'Conteúdo interativo' if splitScreen
						# <div .contentContainer [d:block w:50%] [d:none]=!splitScreen>
							# console.log $container.offsetWidth
							switch contentsData.contentType
								when 'YT'
									# <yt-iframe videoId=contentsData.videoId change=iframeChange width=($container.offsetWidth / 2) height=(($container.offsetWidth / 2) * (9 / 16))>
									<iframe [w:100% h:100%] src="https://www.youtube.com/embed/{contentsData.videoId};start={contentsData.startAt}" frameborder="0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share">
								#	<yt-iframe videoId=contentsData.videoId startAt=contentsData.startAt change=iframeChange>
								when 'slide'
									<iframe src=contentsData.slideUrl [w:100% h:100%] frameborder="0" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true">
								when 'pdf'
									<iframe src=contentsData.fileUrl [w:100% h:100%] frameborder="0">
								when 'website'
									<iframe src=contentsData.websiteUrl [w:100% h:100%] frameborder="0">
								when 'codeEditor'
									# streamerSync=false
									<div.editorsContainer [d:flex w:100% h:100%]>
										console.log codeEditorChange
										<stackblitz-ide streamer=false projectData=contentsData.projectData>
										# <code-editor receiver=true streamer=false change=codeEditorChange>		
										# <code-editor receiver=false streamer=false>		
				<interaction-bar$interaction-bar [b:35%] [b:5%]=splitScreen splitScreen=splitScreen @mouseover=(barFocus=true) @mouseout=(barFocus=false)>
				if contentType === 'quiz'
					<quiz contentsData=contentsData>
				# -----------------------------

				# <div.playerContainer [d:none]=!streamerSync>
				# 	if contentType !== 'camera'
				# 		<button.syncBtt @click=emit('toggleSync', false)> 'Desync' 
				# 	<video-player [my:auto] controls=true autoplay=true showTime=false streamData=streamData>
				
				# <div.contentContainer [d:none]=streamerSync>
				# 	<button.syncBtt @click=emit('toggleSync', true)> 'Sync'
				# 	switch contentType
				# 		when 'YT'
				# 			# <iframe .yt src="{contentsData.videoUrl}?start={contentsData.startAt}" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope" allowfullscreen>
				# 			<yt-iframe videoId='cZRj9Sk0IPc&ab' change=iframeChange>
				# 			# <yt-iframe videoId=contentsData.videoId startAt=contentsData.startAt change=iframeChange>
				# 		when 'slide'
				# 			<iframe src=contentsData.slideUrl frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true">
				# 		when 'pdf'
				# 			<iframe src=contentsData.fileUrl [w:100% h:100%]>
				# 		when 'codeEditor'
				# 			streamerSync=false
				# 			<div.editorsContainer [d:flex]>
				# 				console.log codeEditorChange
				# 				<code-editor receiver=true streamer=false change=codeEditorChange>		
				# 				<code-editor receiver=false streamer=false>		
				
				#	<div.cameraContainer>
				#		<video$camera.cameraVideo controls autoplay>