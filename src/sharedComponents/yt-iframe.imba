# 16:9 aspect ratio

tag yt-iframe

	prop player
	prop videoId = 'M7lc1UVf-VE'
	prop startAt
	prop playing = false
	prop streamer = false
	prop width
	prop height
	prop buffering = false

	@observable change = null
	@autorun def iframeChangeHandler
		if !streamer && change && (change.iframeType === 'yt')
			console.log 'iframe change'
			if change.playing
				player.playVideo()
			if !change.playing
				player.pauseVideo()
			# if buffering
			
			setPlaytime(change.playerTime)

	def setPlaytime(playerTime)
		const time = Math.floor(playerTime)
		player.seekTo(seconds:time, allowSeekAhead:true)


	def awaken
		onYouTubeIframeAPIReady()

	def onYouTubeIframeAPIReady
		height = (width*9)/16
		console.log width, height

		player = new YT.Player('player',
			{
				height: height,
				width: width,
				videoId: videoId,    # 'M7lc1UVf-VE'
				playerVars: {
					playsinline: 1,
					enablejsapi: 1,
					start: startAt
				},
				events: {
				'onReady': onPlayerReady
				}
			}
		)
		# onPlaybackRateChange, 
		if streamer
			player.addEventListener('onStateChange', do(event)
				console.log event.data
				if event.data == YT.PlayerState.PLAYING
					playing= true
				elif event.data == YT.PlayerState.PAUSED
					playing = false
				elif event.data == YT.PlayerState.BUFFERING
					buffering = true
				else
					return
				const data = {
					eventType:'iframeChange'
					iframeType: 'yt'
					playing
					buffering
					playerTime: player.getCurrentTime()
				}
				emit('iframeChange', data)
				buffering = false
			)

	def onPlayerReady
		console.log 'player ready'

	<self>
		<div #player>



# YT.PlayerState.PLAYING
# -1 – unstarted
# 0 – ended
# 1 – playing
# 2 – paused
# 3 – buffering
# 5 – video cued