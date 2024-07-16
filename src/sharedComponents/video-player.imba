import '../pages/stream-page/streamComponents/interaction-bar.imba'
# const videoUrl = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

const leadingZeroFormatter = new Intl.NumberFormat(undefined, {minimumIntegerDigits:2})
def formatDuration(time)
	const s = Math.floor(time % 60)
	const m = Math.floor(time / 60) % 60
	const h = Math.floor(time / 3600)
	if h === 0
		return "{m}:{leadingZeroFormatter.format(s)}"
	else
		return "{h}:{leadingZeroFormatter.format(m)}:{leadingZeroFormatter.format(s)}"

# 16:9 aspect ratio
tag video-player
	# video srcObj eh definido na função awaken de stream-page
	prop streamData
	prop autorender = 60fps
	prop lastVolume = $video.volume
	prop screenMode = ''
	prop controls = true
	prop autoplay = false
	prop showTime = true
	prop wasPaused = null
	prop cursorTimer
	prop barFocus = false
	prop width
	prop showCameraVideo 
	prop splitScreen
	prop interactionBarElement
	prop barFocus

	css *, *::before, *::after box-sizing:border-box
	css self pos:relative
		.video-container pos:relative bgc:black
			w:100% max-width:1000px h:100%
			d:flex jc:center margin-inline:auto
			&.paused .video-controls-container o:1
			@hover .video-controls-container o:1
			&.theater max-width:initial w:100% max-height:90vh
			&.fullscreen max-width:initial w:100% max-height:100vh
			# @focus-within .video-controls-container o:1
		video w:100%
		.theater-btn ml:auto
		.controler-background
			content:"" pos:absolute bottom:0 bg:linear-gradient(to top, rgba(0,0,0,.75), transparent)
			w:100% aspect-ratio:6/1 zi:-1 pointer-events:none
		.video-controls-container pos:absolute
			b:0 l:0 r:0
			c:white
			o:0 transition: opacity 150ms ease-in-out
			
			.controls 
				d:flex g:.5rem p:.25rem ai:center
				button
					bg:none bd:none c:inherit p:0 size:30px fs:1.1 cursor:pointer 
					transition: opacity 150ms ease-in-out
					o:.85 @hover:1
		.volume-container 
			d:flex ai:center
			@hover .volume-slider w:100px transform:scaleX(1)
			.volume-slider
				w:0 origin:left transform:scaleX(0)
				transition:width 150ms ease-in-out, transform 150ms ease-in-out
		.duration-container
			d:flex ai:center g:0.25rem flg:1
		.timeline-container
			h:7px margin-inline:0.5rem 
			# cursor:pointer d:flex ai:center
			@hover .timeline h:100%
			@hover .thumb-indicator --scale:1 l:-7px
			@hover .timeline::before d:block
			@hover .preview-img d:block
			@hover .thumb-img d:block
			.timeline
				bgc:rgba(100,100,100,0.5) h:3px w:100% pos:relative
			.timeline::before
					content:'' pos:absolute l:0 t:0 b:0 r:calc(100% - var(--preview-position) * 100%) bgc:rgb(150,150,150)
			.timeline::after
					content:'' pos:absolute l:0 t:0 b:0 r:calc(100% - var(--progress-position) * 100%) bgc:red
			.thumb-indicator
				--scale:0 pos:absolute h:200% t:-50% l:-3px
				# l:calc(var(--progress-position)*100%)
				bgc:red rd:50%  aspect-ratio:1 / 1
		.streamInfo
			c:white pos:absolute w:100%
			# transform:translateX(-50%) scale(var(--scale)) transition:transform 150ms ease-in-out
			# .preview-img
			# 	pos:absolute h:80px aspect-ratio:16/9 t:-1rem l:calc(var(--preview-position)*100%)
			# 	transform:translate(-50%, -100%)
			# 	rd:0.25rem bd:2px solid white d:none
			# .thumb-img
			# 	pos:absolute t:0 l:0 r:0 b:0 w:100% h:100% d:none
	
	def awaken
		emit('videoElement', $video)

	def togglePlay
		$video.paused ? $video.play() : $video.pause()
	
	def toggleFullScreen
		if document.fullscreenElement == null
			$container.requestFullscreen().then do
				screenMode = 'fullScreen'
		else
			document.exitFullscreen().then do
				screenMode = ''
			
	def toggleMiniPlayer
		if screenMode === 'mini'
			document.exitPictureInPicture()
			screenMode = ''
		else 
			$video.requestPictureInPicture()
			screenMode = 'mini'

	def toggleMute
		if $video.volume > 0
			lastVolume = $video.volume
			$video.volume = 0
		else
			$video.volume = lastVolume

	def volume-icon
		if $video.volume > 0.5
			return 'volume_up'
		if 0 < $video.volume < 0.5
			return 'volume_down_alt'
		if $video.volume == 0
			return 'volume_off'
	
	def handleTimelineUpddate(e)
		
	def handleTouch(e)
		if e.type === 'pointerdown'
			#wasPaused = $video.paused
			$video.pause()
		if e.type === 'pointerup'
			$video.play() unless #wasPaused
		$video.currentTime = e.x
	
	def disappearCursor
		clearTimeout(cursorTimer)
		interactionBarElement.style.display = 'flex'
		document.body.style.cursor = "auto"
		$info.style.display = 'block'
		if !barFocus
			cursorTimer = setTimeout(&,2000) do
				document.body.style.cursor = "none"
				$info.style.display = 'none'
				if !splitScreen && !barFocus
					interactionBarElement.style.display = 'none'

	def handleMouseOut
		clearTimeout(cursorTimer)
		if  barFocus
			interactionBarElement.style.display = 'flex'
		if !splitScreen && !barFocus
			interactionBarElement.style.display = 'none'
		$info.style.display = 'none'

	def render
		width = $timeline.getBoundingClientRect().width
		let percent = $video.currentTime / $video.duration
		let playheadPosition = percent * width
		$timelineContainer.style.setProperty('--preview-position', "{percent}")
		<self
			@click=console.log( $video.videoWidth)
			@hotkey('right')=($video.currentTime += 5)
			@hotkey('left')=($video.currentTime -= 5)
			@mousemove=disappearCursor
			@mouseout.wait=handleMouseOut
		>
			<div$container.video-container .paused=$video.paused .theater=(screenMode==='theater') .fullscreen=(screenMode==='fullScreen')>
				<img.thumbnail-img>
				<div.controler-background>
				<div.video-controls-container > if controls
					<div$timelineContainer.timeline-container @mousemove=handleTimelineUpddate @touch.stop.fit($timelineContainer, 0, $video.duration)=handleTouch>		
						<div$timeline .timeline >
							<img.preview-img>
							<div$thumb.thumb-indicator 
								[x:{playheadPosition}px]
							>

					<div.controls>
						<button.play-pause-btn
							@click=togglePlay
							@hotkey('space') @hotkey('k')
						>
							<span .material-icons> "{$video.paused ? 'play_arrow' : 'pause'}"
						<div.volume-container>	
							<button.mute-btn
								@click=toggleMute
								@hotkey('m')
							>
								<span .material-icons> volume-icon()
							<input.volume-slider type='range' min='0' max='1' step='any' value='1' contentsData=$video.volume>
						<div.duration-container [d:none]=!showTime>
							<div.current-time> formatDuration($video.currentTime)
							'/'
							<div.total-time> formatDuration($video.duration) if $video.duration
						<button.theater-btn 
							@click=(screenMode==='theater' ? screenMode='' : screenMode='theater')
							@hotkey('t')
						>
							<span .material-icons> "crop_7_5"
						<button.picture-in-picture-btn
							@click=toggleMiniPlayer
							@hotkey('i')
						>
							<span .material-icons> "picture_in_picture_alt"
						<button.full-screen-btn
							@click=toggleFullScreen
							@hotkey('f')
						>
							<span .material-icons> "{screenMode==='fullScreen' ? 'fullscreen_exit' : 'fullscreen'}"
				<video$video @click=togglePlay autoplay=autoplay>
					<track kind='caption' srclang='pt' src=''>
				# if showCameraVideo
				<CameraVideo [d:none]=!showCameraVideo>
				<div$info .streamInfo>
					<span> 'Stream info'
					<button @click=emit('toggleSubscription')> streamData.subscribed ? 'unsubscribe' : 'subscribe'
				# <interaction-bar$interaction-bar @focusin=(barFocus=true) @focusout=(do barFocus=false; disappearCursor())>
				
tag CameraVideo

	def awaken
		emit('cameraElement', $camera)

	def build
		x = 300
		y = 250

	css self bgc:cool4 pos:absolute
		.videoContainer w:200px d:vflex jc:flex-end bd:1px solid blue4
		video w:100%
		.topBar bgc:blue4 cursor:grab

	<self [x:{x} y:{y}] @touch.moved.sync(self)
		# [d:none]=(!$camera.srcObject)
	>
		<div.videoContainer>
			# <div.topBar> 'drag'
			# 	<button> 'sync'
			<video$camera autoplay controls>


# screenshot_monitor  ICON	
# cast ICON					

