tag alert-box

	prop show = true
	prop txt = 'hiiiiiiiiiiiiiiiiiiiiiiiiiiiii'
	prop persist = 5000

	css pos:absolute size:70px w:500px bgc:hsla(198,93%,59%,0.5) rd:xl shadow:xl
		l:50% t:15% x:-50% y:-50% d:vflex ai:flex-end
	css span fs:1.5rem as:center
	css button bd:none rd:50%
		bgc:rgba(0,0,0,0) @hover:red4/50

	def mount
		setTimeout(&, persist) do
			show = false
			imba.commit()	

	def render
		<self
		[d:none]=!show
		>
			<button @click=(show=false)> 'x'
			<span> txt

