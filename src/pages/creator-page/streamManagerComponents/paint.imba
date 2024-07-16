
const strokes = [1,2,3,5,8,12]
const colors = ['#F59E0B','#10B981','#3B82F6','#8B5CF6']
const state = {stroke: 3, color: '#3B82F6', transparent: true}

tag paint

	prop canvas
	prop dpr = window.devicePixelRatio  # =1
	prop ctx
	prop state

	def clearCanvas
		ctx.clearRect(0, 0, canvas.width, canvas.height)

	css m:0 p:0 of:hidden rd:lg h:100% w:100%
		.tools pos:abs w:500px d:flex ja:center g:20px

	<self >
		<canvas-to-draw dpr=dpr ctx=ctx state=state
			@canvas=({canvas, ctx} = e.detail; state.ctx=ctx; state.canvas=canvas)
		>

tag canvas-tools

	# prop state

	# def mount
	# 	x = y = 50

	css .tools w:450px d:flex ja:center g:20px rdb:10px

	<self [x:{x} y:{y}] @touch.moved.sync(self)>

		<div.tools [t:0 bgc:hsla(48, 96%, 76%, 0.5)]>
			<stroke-picker options=strokes bind=state.stroke>
			<color-picker options=colors bind=state.color>
			<button @click=(state.transparent=!state.transparent)
			> state.transparent ? 'claro' : 'transparente'
			<button @click=state.ctx.clearRect(0, 0, state.canvas.width, state.canvas.height)> 'limpar'
			<button @click=emit('togglePaint')> 'X'

tag canvas-to-draw
	prop dpr = window.devicePixelRatio  # =1
	prop ctx
	prop state = {}

	def awaken
		ctx = $canvas.getContext('2d')
		ctx.strokeRect(0, 0, $canvas.width, $canvas.height)
		const data = {
			canvas: $canvas
			ctx
		}
		emit('canvas', data)

	def draw(e)
		let path = e.$path ||= new Path2D # if falsy assignment
		path.lineTo(e.x * dpr, e.y*dpr)
		ctx.lineWidth = state.stroke * dpr
		ctx.strokeStyle = state.color
		ctx.stroke(path)

	def resized
		$canvas.width = offsetWidth * dpr
		$canvas.height = offsetHeight * dpr

	css self 
			w:100% h:100%
			canvas w:100% h:100%

	<self
		@resize=resized
		@touch.prevent.moved.fit(self)=draw
	>
		<canvas$canvas [bgc:hsla(48, 96%, 76%, 0.1)] [bgc:amber2 o:1]=(!state.transparent)>

tag paint-tools

	prop state
	prop strokes
	prop colors

	<self>
		<div.tools>
			<stroke-picker options=strokes bind=state.stroke>
			<color-picker options=colors bind=state.color>

tag value-picker

	prop options
	
	css w:100px h:40px pos:rel
		d:hgrid ji:center ai:center
	css .item h:100% pos:rel tween:styles 0.1s ease-out

	def update(e)
		data = options[e.x]

	<self
		@touch.stop.fit(0, options.length - 1, 1)=update
	>
		for item in options
			<div.item[$value:{item}] .sel=(item==data)>


tag stroke-picker < value-picker
	css .item bg:black w:calc($value*1px) h:40% rd:sm
		o:0.3 @hover:0.8 .sel:1


tag color-picker < value-picker
	css .item s:20px js:stretch rd:lg bg:$value mx:2px scale-y.sel:1.5

