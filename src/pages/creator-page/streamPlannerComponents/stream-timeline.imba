
import plus from '../../../assets/icons/plus-icon.svg'
import previous from '../../../assets/icons/anterior-seta-icon.svg'
import next from '../../../assets/icons/proximo-seta-icon.svg'
import deleteBtt from '../../../assets/icons/delete-button-icon.svg'



tag stream-timeline
	
	prop contentsData
	prop currentIndex = 0
	prop contentToEdit
	prop user

	css self 
			d:vflex h:100% w:100% bg:var(--ui-container)
		.controls
			w:100%
			h:20%
			display: inline-flex;
			# padding: 0.875rem 38.8125rem 0.9375rem 2.375rem;
			align-items: center;
			# gap: 10rem;
			jc:space-between
			.buttonsBox
				d:flex g:0.5rem
		.contents
			box-sizing: border-box
			display: flex;
			pl:2rem
			ai:start
			width: 100%
			height: 80%;
			# padding: 0rem 0.9375rem;
			# align-items: flex-start;
			gap: 2rem;
			flex-shrink: 0;
			border-top: 1px solid #454545;
			background: var(--uibg, #171419);
			overflow-x:auto

	def changeCurrentContent(type)
		if type === "previous"
			currentIndex = Math.max(0, currentIndex - 1)
		elif type === "next"
			currentIndex = Math.min(contentsData.length - 1, currentIndex + 1)
		else
			currentIndex = type
		emit('editContent', currentIndex)

	<self>
		<div.controls>
			<button-arandu svg=plus text='Novo conteúdo interativo' preIcon=true [ml:1rem w:14rem fs:0.8rem h:2rem bg:var(--roxo-arandu)]
			@click=emit('popup', 'newContent')
			>
			<div.buttonsBox>
				<svg type="button" @click=changeCurrentContent('previous') src=previous>
				<svg type="button" @click=changeCurrentContent('next') src=next>
			<button-arandu [h:2rem w:5rem mr:1rem] text='Salvar' @click=emit('salvarStream') route-to="/{user.uid}/creator/selection" >
		<div.contents>
			for item, index of contentsData
				if item
					<timeline-item item=item index=index 
					# selected=(contentToedit && index == contentToEdit.index)
					selected=(index == currentIndex)
					>
					<div.line [width:0.0625rem height:100% opacity:0.2 background:#7B7B7B;]>

			<svg [o:0.2 as:center] src=plus>

		# <h4 [m:0 mb:1em]> "Linha do tempo de conteúdos"
		# <div.timelineContainer [d:flex]>
		# 	if contentsData.length === 0
		# 		<p> "nenhum conteúdo inserido aPytinda"
		# 	else
		# 		<div [w:50px h:1.2rem bgc:emerald4 as:center ta:center]> "Início"
		# 		for item,index of contentsData
		# 			if item
		# 				<timeline-item item=item index=index>
	# <self>
	# 	<h4 [m:0 mb:1em]> "Linha do tempo de conteúdos"
	# 	<div.timelineContainer [d:flex]>
	# 		if contentsData.length === 0
	# 			<p> "nenhum conteúdo inserido aPytinda"
	# 		else
	# 			<div [w:50px h:1.2rem bgc:emerald4 as:center ta:center]> "Início"
	# 			for item,index of contentsData
	# 				if item
	# 					<timeline-item item=item index=index>					


tag timeline-item
	prop item
	prop index
	prop selected = !true
	prop showDelete = false

	# css .contentBlock
	# 	size:75px
	# 	bgc:cool4
	# 	p:0.2em
	# 	d:flex
	# 	fld:column
	# 	jc:end
	# 	cursor:pointer
	# 	@hover size:80px bgc:green4

	# css .deleteBtt fs:0.7rem m:0 mt:auto 
	# 	@hover td:underline cursor:pointer

	css self
			pos:relative
			display: vflex;
			padding: 0.25rem 0.5rem;
			align-items: center;
			gap: 0.2rem;
			border-radius: 0.25rem;
			background: #151515;
			cursor:pointer
			t:0.5rem
			w:6rem
			h:8rem
			&.selected border: 2px solid #E58320
		.index
			fs:0.7rem
		.thumbnail
			aspect-ratio: 16 / 9
			width: 99%;
			bg:white
			border-radius: 0.25rem;
			background: white
			# background: url(<path-to-image>), lightgray 50% / cover no-repeat, #222;
		.type
			fs:0.8rem
		.red
			all:unset
			pos:absolute
			cursor:pointer
			display: flex;
			s:1rem
			padding: 0.36844rem;
			justify-content: center;
			align-items: center;
			border-radius: 0.25rem;
			background: #C11313;
			t:6.5rem

	<self .selected=selected 
		# @click=(selected = !selected)
		@click=emit('editContent', index)
		@mouseover=(showDelete = true)
		@mouseleave=(showDelete = false)
	>
		<div.index> "{index + 1}"
		<div.thumbnail>
		<div.type> item.contentType
		# if selected
		if showDelete || selected
			<button.red>
				<svg src=deleteBtt @click.stop=emit('deleteContent', index)>
			# <button.contentBlock .selected@click @click=emit('editContent', index)>
			# 	<h5 [as:center m:0]> "{item.contentType}"
			# 	<p.deleteBtt @click.stop=emit('deleteContent', index)> "Remover"



