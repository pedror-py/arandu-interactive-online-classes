


tag mouse-sim

	prop posX
	prop posY


	css self d:flex
		.senderContainer s:100px bgc:cool4
		button pos:absolute

	def mousePos(e)
		let rect = e.target.getBoundingClientRect()
		# console.log rect
		# console.log e.x, e.y
		posX = e.x - rect.x
		posY = e.y - rect.y

	def mouseClick(e)
		mousePos(e)
		# console.log posX, posY
		$mirror.simClick(posX, posY)

	<self>
		<div.senderContainer @mousemove=mousePos @click=mouseClick>
			<button> 'click'


		<mirror$mirror posX=posX posY=posY>



tag mirror

	prop autorender=10fps

	prop posX
	prop posY
	prop mirrorRect
	prop containerRect


	def setup


	def simClick(x, y)
		let docX = x + containerRect.x
		let docY = y + containerRect.y
		const clickEvent = new MouseEvent('click', {
			view:window
			screenX:x
			screenY:y
			bubbles:true
		})
		# const target = document.elementFromPoint(docX, docY)
		console.log docX, docY
		$mask.dispatchEvent(clickEvent)

	css self
		.container s:100px bgc:emerald4
		.mirrorMouse s:5px bgc:black
		.mask s:100px pos:absolute
		button pos:absolute


	def render
		mirrorRect = $mirrorMouse.getBoundingClientRect()
		containerRect = $container.getBoundingClientRect()

		# console.log containerRect
		<self>
			<div$mask .mask>
				<div$container.container @click.log('container')>
					<button @click.log('clicked!')> 'click'
					<div$mirrorMouse .mirrorMouse [x:{posX} y:{posY}]>
					# rect = $mirror.getBoundingClientRect()
					# console.log(mirrorRect.x - containerRect.x)

