
import close from '../../../assets/icons/x-close-icon.svg'

tag edit-stream-data < modal

	prop data = {
		title: ''
		tags: []
		category: ''
		dateTime: null
	}
	prop tagText = ''
	
	def updateStreamData
		emit('updateStreamData', data)
		# emit('closeModal')
		# emit('salvarStream')

	def addTag
		data.tags.push(tagText); 
		tagText = ''

	css
		.container
			# pos:absolute l:50% x:-50%
			align-items: flex-start
			border-radius: 0.5rem
			border: 1px solid rgba(0, 0, 0, 0.35)
			box-shadow: 0px 3px 11px 4px rgba(0, 0, 0, 0.2)
			background-color: var(--ui-container, #27232a)
			display: flex
			flex-direction: column
			padding: 0 24px
			@media(max-width: 991px)
				padding: 0 20px
		.header
			align-self: stretch
			color: var(--principal-branco, #fff)
			margin-top: 24px
			font: 500 1rem/150% Poppins, sans-serif
		.title
			align-self: stretch
			color: var(--principal-branco, #fff)
			opacity: 0.8
			margin-top: 24px
			font: 400 0.88rem/150% Poppins, sans-serif
		.input-field
			color: var(--principal-branco, #fff)
			border-radius: 0.3125rem
			background-color: var(--ui-text-input, #413947)
			align-self: stretch
			margin-top: 8px
			padding: 14px 16px
			font: 400 0.88rem/150% Poppins, sans-serif
		.section
			align-self: stretch
			display: flex
			margin-top: 24px
			flex-direction: column
		.section-title
			color: var(--principal-branco, #fff)
			opacity: 0.8
			font: 400 0.88rem/150% Poppins, sans-serif
		.section-content
			# border-radius: 0.3125rem
			# background-color: var(--ui-text-input, #413947)
			# display: flex
			margin-top: 8px
			# flex-direction: column
			# padding: 14px 16px
		.placeholder-text
			color: var(--principal-branco, #fff)
			opacity: 0.5
			font: 400 0.88rem/150% Poppins, sans-serif
		.add-tag-button
			color: var(--branco-arandu)
			text-align: center
			justify-content: center
			border-radius: 0.5rem
			border: 1px solid var(--apoio-roxo, rgba(255, 255, 255, 0.26))
			background-color: var(--roxo-arandu)
			align-self: start
			margin-top: 8px
			width: 115px
			max-width: 100%
			padding: 8px
			font: 500 0.88rem/150% Poppins, sans-serif
		.gallery
			align-items: start
			align-self: stretch
			border-radius: 0.375rem
			background-color: var(--ui-text-input, #413947)
			display: flex
			margin-top: 24px
			width: 100%
			justify-content: space-between
			gap: 16px
			# padding: 18px 71px 18px 16px
			@media(max-width: 991px)
				padding-right: 20px
		.item
			border-radius: 4.875rem
			border: 2px solid rgba(229, 131, 32, 0.3)
			background-color: var(--principal-laranja, #e58320)
			display: flex
			gap: 8px
			padding: 4px 16px
		.label
			color: #fff
			font: 400 0.88rem/150% Poppins, sans-serif
		.image-icon
			aspect-ratio: 1
			object-fit: contain
			object-position: center
			width: 16px
			overflow: hidden
			align-self: center
			max-width: 100%
			margin: auto 0
			cursor:pointer
		.category
			align-self: stretch
			color: var(--principal-branco, #fff)
			opacity: 0.8
			margin-top: 24px
			font: 500 0.88rem/150% Poppins, sans-serif
		# .schedule-section
		# 	align-self: stretch
		# 	color: var(--principal-branco, #fff)
		# 	opacity: 0.8
		# 	margin-top: 24px
		# 	font: 400 0.88rem/150% Poppins, sans-serif

		# .schedule-action
		# 	border-radius: 0.3125rem
		# 	background-color: var(--ui-text-input, #413947)
		# 	align-self: stretch
		# 	display: flex
		# 	margin-top: 8px
		# 	flex-direction: column
		# 	padding: 14px 16px

		# .action-text
		# 	color: var(--principal-branco, #fff)
		# 	opacity: 0.5
		# 	font: 400 0.88rem/150% Poppins, sans-serif
		.save-button
			margin: 24px 0
			padding: 12px 20px

	def render
		# let time = data.dateTime.toDate()
		# time = formatDate(time)
		<self  @click.self=emit('closeModal')>
			<form.container @submit.prevent.log('foi')=updateStreamData>
				<div.header> "Editar dados da stream"
				<input-arandu.category label='Título' placeholder="Escrever..." bind:value=data.title>

				<input-arandu.category label='Tags' placeholder="Escrever..." bind:value=tagText>	
				<div.add-tag-button @click=addTag> "Adicionar Tag"
				<div.gallery>
					for streamTag, i in data.tags
						<div.item>
							<div.label> streamTag
							<svg.image-icon loading="lazy" src=close
								@click=data.tags.splice(i, 1)
							> 'x'
					
				
				# <div.category> "Categoria"
				# <div.selection-area>
				# 	# <div.selection> "Selecionar"
				# 	<img.loading="lazy" src="" class="selection-icon">
				<select-arandu.category [w:inherit] .category label='Categoria' placeholder='Escrever...' bind:value=data.category>
				<input-arandu .category label="Agendar transmissão (opcional)" type='datetime-local' placeholder='Escrever...' bind:value=time>
				
				# <div.schedule-section> "Agendar transmissão (opcional)"
				# <div.schedule-action>
				# 	<div.action-text> "Agendar transmissão"
				
				# <div.save-button> "Salvar"
				<button-arandu.save-button type='submit' text='Salvar'>



# tag edit-stream-data-2

# 	prop data = {
# 		title: ''
# 		tags: []
# 		category: ''
# 		dateTime: null
# 	}
# 	prop title
# 	prop useDatetime = false

# 	css h:100% w:100%
# 		label d:block
# 		form h:100% w:100% d:vflex ai:flex-start
# 		.closeBtts mt:auto as:flex-end
	
# 	def updateStreamData
# 		emit('updateStreamData', data)

# 	<self>
# 		<form @submit.prevent=updateStreamData>
# 			<h3> 'Editar dados da stream'
# 			<label> 'Título'
# 			<input type='text' bind=data.title>
# 			<label> 'Tags'
# 			<input$tag type='text'>
# 			<button type='button' @click=(data.tags.push($tag.value); $tag.value='') > 'Adicionar tag'
# 			for streamTag, i in data.tags
# 				<div.tag>
# 					<span> streamTag
# 					<button type='button' @click=data.tags.splice(i, 1)> 'x'
# 			<label> 'Categoria'
# 			<input type='text' placeholder='Procurar uma categoria' bind=data.category>
# 			if useDatetime
# 				<label> "Agendar transmissão"
# 				<input type='datetime-local' bind=data.dateTime>

# 			<div.closeBtts>
# 				<button type='reset' @click=emit('closePopUp')> 'Cancelar'
# 				<button type='submit'> 'Concluir'
