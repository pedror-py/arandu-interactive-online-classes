const videoUrl = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

tag draggable-miniwindow

	prop showControls=false
	prop width

	css pos:relative d:block zi:1000
		.miniplayer w:200px
		.miniwindow size:20 m:0 pos:relative d:block bgc:blue
		.control h:5 w:20 bgc:red 
			cursor:grab @touch.moved:grabbing
			d:none .show:block @hover:block	

	def build
		x = y = 0

	def render
		<self [x:{x} y:{y}] 
		@touch.moved.sync(self)
		>
			<div.container>
				<div.control .show=showControls > "drag"
				<video.miniplayer controls
					src=videoUrl
					@mouseenter=(showControls=true)
					@mouseleave=(showControls=false)
				> 
