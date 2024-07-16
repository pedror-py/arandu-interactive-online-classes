import "../stream-planner.imba"
import { nanoid } from 'nanoid'

const letrasNum = {0:'a', 1:'b', 2:'c', 3:'d', 4:'e', 5:'f'}

tag quiz-maker
	prop txtResposta = ''
	prop txtPergunta= ''
	prop respostas= []
	prop respostaCorreta = false
	prop editing = null

	def novaResposta
		const letra = letrasNum[respostas.length]
		const respostaInfo = {letra, txtResposta, respostaCorreta}
		respostas.push(respostaInfo)
		respostaCorreta = false
		txtResposta = ""

	def deleteResposta(index)
		respostas.splice(index, 1)

	def resetData
		txtResposta = ''
		txtPergunta= ''
		respostas= []
		respostaCorreta = false
	
	def handleSubmit
		const contentData = {
		contentType: 'quiz'
		quizId: nanoid()
		pergunta: txtPergunta
		respostas
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		resetData()

	css h:100%
		form d:vflex h:100%
		.option d:flex m:0.5em w:20rem rd:md overflow-wrap:break-word
			bd:thin solid cooler4     
			&.correta bd:2px solid emerald4
		button ml:auto
		.preview flg:1

	css	h3,h4,h5
		m:0.5em

	def render
		if editing!== null && typeof(editing)=='object'
			txtPergunta = editing.contentData.pergunta
			respostas = editing.contentData.respostas
			editing=true
			
		<self>
			<form 
			@submit.prevent.log('submited')=handleSubmit
			@reset=resetData>
				<h5 [m:5px]> "Adicionar uma quiz"
				<div.perguntaContainer>
					<label> 'Adicione a pergunta'
						<br>
						<input name="pergunta" type='text' id='pergunta' bind=txtPergunta required>
						<br>
				<div.optionContainer>
					<label> 'Insira uma opção de resposta: '
						<br>
						<input name='resposta' type='text' id='resposta' bind=txtResposta>
					<label> "   resposta correta?"
						<input type='checkbox' id='check' bind=respostaCorreta>
					<br>
					<button type='button' @click=novaResposta> "Adicionar opção de resposta"
				<div.preview>
					<h4> 'Pergunta:	'
						<span> txtPergunta
					for resposta,index of respostas
						let {letra, txtResposta, respostaCorreta:correta} = resposta
						<div.option .correta=correta> 
							<h5> "{letra}.	{txtResposta}"
							<button type='button' [ml:auto] @click=(do(index) deleteResposta(index))> "X"
				<submit-btt editing=editing>



# tag resposta-option

# 	prop txt = ''
# 	prop correto = false
# 	prop letra = ''
# 	prop selecionada = false
# 	prop index

# 	css .selected
# 		bd:thin green

# 	def selectAnswer
# 		selecionada = !selecionada
# 		emit('selected', {index, selecionada})

# 	<self>
# 		<div .selected@click>
# 			<button @click=selectAnswer>
# 				<p> "{letra}.	{txt}"