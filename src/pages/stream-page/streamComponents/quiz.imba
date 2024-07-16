
tag quiz

	prop confirmed = false
	prop showResults = false
	prop correctAnswer = false
	prop noneSelected = null
	prop timeRemaining = null
	# prop autorender = 10fps
	prop interval
	prop contentsData

	def awaken
		for res, i of contentsData.respostas
			res.selected= false
			res.index= i
			res.acertou= false
		if contentsData.time
			timeRemaining = contentsData.time/1000
			interval = setInterval(&, 1000) do
				timeRemaining -= 1
	
	def build
		x = y = 0

	def toggleSelection(e)
		let {index, selected} = e.detail
		contentsData.respostas.map do(res, i)
			if contentsData.multi
				if i == index
					res.selected = selected
			else
				i==index ? (res.selected = selected) : (res.selected = false)
	
	def confirmAnswer
		correctAnswer = true
		noneSelected = true
		for res, i of contentsData.respostas
			if res.selected
				noneSelected = false
				contentsData.answerIndex = i
			if res.selected && res.respostaCorreta
				res.acertou = true
				contentsData.gotRight = true
			if res.selected && !res.respostaCorreta
				res.acertou = false
				contentsData.gotRight = false
			if res.acertou === false
				correctAnswer = false
		if noneSelected === true
			return
		confirmed = true
		emit('quizAnswered', contentsData)
		

	css bg:var(--ui-container) w:25rem max-height:25rem rd:xl zi:99999 font-family:Poppins
		pos:absolute p:5px
		.quiz c:var(--principal-laranja) font-size:1.2rem
		.quizbox d:vflex g:.25em p:.25em
		.pergunta m:0.25em
		hr c:black mb:0.25em w:19rem
		.confirmBtn as:flex-end

	def render
		let barWidth = (20/(contentsData.time/1000))*timeRemaining
		if timeRemaining === 0
			confirmed = true
			showResults = true
			clearInterval(#interval)
		<self	
			[x:{x} y:{y}] 
			@touch.moved.sync(self)
		>
			<div.quizbox>
				<div.quiz> 'Quiz'
				if contentsData.time
					<p [m:0]> "{timeRemaining}"
				<div.pergunta> contentsData.pergunta
					<hr [w:{barWidth}rem]>
				for res of contentsData.respostas
					if showResults
						<quiz-option
							contentsData=res
							showResults=true
						>
					else
						<quiz-option
							contentsData=res
							index=res.index
							selected=res.selected
							disabled=confirmed
							@selected=toggleSelection
						>
				if !confirmed and !showResults
					<p [m:0 ta:center]> "Selecione uma resposta primeiro" if noneSelected
					# <button.confirmBtn @click=confirmAnswer disabled=confirmed> 'Confirmar'
					<button-arandu [w:100%] text='Confirmar' @click=confirmAnswer disabled=confirmed>
				if confirmed and !showResults
					<p [m:0 ta:center]> "Sua resposta foi enviada"
					<button @click=(showResults=true)> "Mostrar resultados" if !showResults
				if confirmed and showResults
					if correctAnswer
						<p [m:0 ta:center]> "Resposta Correta!"
					else
						<p [m:0 ta:center]> "Resposta Errada :("

tag quiz-option

	prop index
	prop selected = false
	prop disabled = false
	prop showResults
	prop acertou

	def selectAnswer
		selected = !selected
		emit('selected', {index, selected})

	css .optionbox
			&.selected bd:4px solid emerald4
		.btn
			&.correctAnswer bgc:emerald4
			&.wrongAnswer bgc:red5
		button w:100%
			bg:var(--ui-text-input) c:var(--principal-branco) font-family:Poppins
		p ta:left
		span mr:0.5em

	<self>
		if showResults
			<div.optionbox .selected=selected>
				<button.btn .correctAnswer=contentsData.respostaCorreta .wrongAnswer=(contentsData.selected && !contentsData.respostaCorreta)>
					<p> 
						<span> "{contentsData.letra})"
						"	{contentsData.txtResposta}"
		else
			<div.optionbox .selected=selected>
				<button @click=selectAnswer disabled=disabled>
					<p> 
						<span> "{contentsData.letra})"
						"	{contentsData.txtResposta}"