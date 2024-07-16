tag aux-sidebar-icons

	prop chatOpen

	css w:3rem h:100% 
		d:vflex g:5px pos:fixed zi:1000
		button bgc:clear cursor:pointer bd:none
		span fs:40px c:white
			o:0.6 @hover:1

	<self>
		<button @click=(emit('openSidebar', 'results')) [mt:50px]>
			<span .material-icons> 'biotech'
		<button @click=(emit('openSidebar', 'perguntas'))>
			<span .material-icons> 'question_answer'
		<button @click=(emit('openSidebar', 'content'))>
			<span .material-icons> 'source'
		<button @click=(emit('openSidebar', 'notes'))>
			<span .material-icons> 'lightbulb'
		<button @click=(emit('openSidebar', 'chat')) disabled=!chatOpen >
			<span .material-icons [o:0.2 cursor:not-allowed]=!chatOpen> 'chat'


# <div style="background-color:rgba(0, 0, 0, 0.5);">
#    <div>
#       Text added.
#    </div>
# </div>