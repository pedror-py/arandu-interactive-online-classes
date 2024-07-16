tag sentiment-pannel

	prop video\HTMLVideoElement

	css button bd:none rd:50% bgc:black

	<self>
		<div.container>
			<button  @click=emit('sendSentiment', 'love') type='button'>
				<span .material-icons [c:red4]> 'favorite'
			<button  @click=emit('sendSentiment', '?') type='button'>
				<span .material-icons [c:yellow2]> 'help'
			# <button  @click=emit('sendSentiment', 'sim') type='button'> 'Sim!'
			# <button  @click=emit('sendSentiment', 'nao') type='button'> 'Não!'
			# <button  @click=emit('sendSentiment', 'haha') type='button'> 'haha'
			# <button  @click=emit('sendSentiment', 'meh') type='button'> 'meh'
