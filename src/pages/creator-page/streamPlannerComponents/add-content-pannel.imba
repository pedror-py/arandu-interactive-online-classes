const contents = {
	YT: {
		btt: "YT video"
		description:"Adiciona um video do YouTube para ser assistido junto aos alunos"
		}
	video:{
		btt: "Video"
		description:"Adiciona um arquivo de vídeo para ser assistido junto aos alunos"
		}
	pdf:{
		btt: "PDF"
		description: "Adiciona um pdf para ser visualizado junto aos alunos"
		}
	slide:{
		btt: "Apresentação de slide"
		description:"Adicona uma apresentação de slides do Microsoft Power Point ou do Google Slides"
		}
	img:{
		btt: "Imagem"
		description:""
		}
	quiz:{
		btt: "Quiz"
		description:"Crie uma quiz para ser respondida em tempo real por quem assiste"
		}
	website:{
		btt: "Website"
		description: "Adicione outros websites para serem acessados por você e pelos alunos"
		}
	editor:{
		btt: "Editor de código"
		description: "Utilizar editor de código em tempo real"
		}

	# pesquisa:{
	# 	btt: "Realizar uma pesquisa"
	# 	description:""}
	# perguntas:{
	# 	btt: "Responder às perguntas"
	# 	description:"Pausa para responder às perguntas feitas pelos alunos"}
	# explic:{
	# 	btt: "Explicar um conteúdo"
	# 	description:""}
}

tag add-content-pannel < modal

	prop description = ""
	prop displayContentType

	css self
		section
			border-radius: 0.5rem
			border: 1px solid rgba(0, 0, 0, 0.35)
			box-shadow: 0px 3px 11px 4px rgba(0, 0, 0, 0.2)
			background-color: var(--ui-container, #27232a)
			# padding: 0 24px
			w:50rem h:25rem
		.container
			w:100% h:90%
			display:flex
			align-items: center
			jc:space-between
		.addContentPannel 
			d:vflex w:30% h:90%
		.example
			bgc:gray
			w:50% h:90% mr:2rem
		button h:2.3rem

	<self @click.self=emit('closeModal')>
		<section>
			<div.container>
				<div.addContentPannel>
					<div> "Adiconar conteúdo"
					for own key, value of contents
						<button
						@click=emit('newContent', key)
						@mouseover=(description=value.description) 
						@mouseleave=(description="")
						[bgc:green4]=(displayContentType == key)
						> "{value.btt}"
				<div.example>	
			<div> description ? "{description}" : "    "