

tag move-video

	prop containerWidth
	prop containerHeight
	prop boxTop
	prop boxLeft
	prop firstRender = true

	def awaken

	
	css self
		.big s:500px

	def render
		if firstRender
			containerWidth = $container.width
			containerHeight = $container.height
			boxTop = continerHeight - $small.height
			boxLeft = continerWidth - $small.width
			console.log $container


			firstRender = false
		<self>
			<div$container.big [ bgc:rose4 pos:relative]>
				<video$video controls [w:100% h:100%]>
				<small-box$small [s:100px bd:2px solid black pos:absolute t:0 l:0] >



tag small-box

	def build
		x = y = 0

	def update(e)
		if e.type = 'pointerup'

	def render
		# console.log x, y
		<self [x:{x} y:{y}] 
		@touch.moved.sync(self)
		>