
import plus from '../../../assets/icons/plus-icon.svg'
import play from '../../../assets/icons/play-button-icon.svg'
import edit from '../../../assets/icons/edit-button-icon.svg'
import deleteBtt from '../../../assets/icons/delete-button-icon.svg'

tag planned-streams

	prop user
	prop plannedStreams
	prop inPlanner = true
	prop showSidebar

	css self
			w:100% h:100% bg:#171419
			flex-shrink: 0;
			d:vflex
			g:1rem
			# pt:1.75rem
		.container
			display: flex;
			width: 90%;
			flex-direction: column;
			align-items: flex-start;
			gap: 0.5rem;
			font-family: Poppins;
			ml:1rem

	def render
		if imba.router.path.split('/')[-1] === 'manager'
			inPlanner = false
		else
			inPlanner = true

		# <self [w:calc(100% - 13.25rem)]=showSidebar>
		<self>
			<div.optionButtons>
			<button-arandu [w:20rem h:2.5rem ml:1rem]
				text="Planejar nova transmissão" 
				route-to="/{user.uid}/creator/planned/new"
				svg=plus
				preIcon=true
			>
			# <button 
			# route-to="/{user.uid}/creator/planned/new"> "Planejar nova transmissão"
			# <button route-to="/{user.uid}/creator/selection/planned"> "Editar transmissões planejadas"
			<div.container>
				# <div.plannedStreamsContainer>
				<div> "Transmissões planejadas"
				for stream, i of plannedStreams
					<planned-stream-item
						user=user
						stream=stream.data() 
						streamId=stream.id 
						index=i 
						inPlanner=inPlanner
					>
			if !inPlanner
				<button 
					@click=emit('newStream', false)
					
				> 'Iniciar uma nova transmissão'

	# def render
	# 	if imba.router.path.split('/')[-1] === 'manager'
	# 		inPlanner = false
	# 	else
	# 		inPlanner = true

	# 	<self [w:calc(100% - 13.0625rem)]=showSidebar>
	# 		if inPlanner
	# 			<div.optionButtons>
	# 				<button 
	# 				route-to="/{user.uid}/creator/planned/new"> "Planejar nova transmissão"
	# 		else
	# 			<button route-to="/{user.uid}/creator/selection/planned"> "Editar transmissões planejadas"
	# 		<div> "Transmissões planejadas"
	# 		<div.plannedStreamsContainer>
	# 			for stream, i of plannedStreams
	# 				<planned-stream-item
	# 					user=user
	# 					stream=stream.data() 
	# 					streamId=stream.id 
	# 					index=i 
	# 					inPlanner=inPlanner
	# 				>
	# 		if !inPlanner
	# 			<button 
	# 				@click=emit('newStream', false)
					
	# 			> 'Iniciar uma nova transmissão'

tag planned-stream-item

	prop user
	prop stream
	prop streamId
	prop index
	prop inPlanner

	css self
			w:100%
			display: flex;
			flex-shrink: 0;
			padding: 0.5rem;
			justify-content: space-between;
			align-items: center;
			align-self: stretch;
			border-radius: 0.25rem;
			background: var(--ui-container, #27232A);
		.streamInfo
			display: flex;
			width: 90%;
			align-items: center;
			gap: 1rem;
			.title
				display: -webkit-box;
				-webkit-box-orient: vertical;
				-webkit-line-clamp: 1;
				flex-shrink: 0
				w:60%
				overflow: hidden;
				text-overflow: ellipsis
			.dateTime
				font-size: 0.7em
				opacity: 0.8
		.buttons
			display: flex;
			align-items: center;
			gap: 0.5rem;
			button
				all:unset
				cursor:pointer
				display: flex;
				# width: 2rem;
				# height: 2rem;
				padding: 0.36844rem;
				justify-content: center;
				align-items: center;
				border-radius: 0.25rem;
				&.red
					background: #C11313;
				&.white
					bg:white
				
	def render
		# if stream.dateTime
		
		# const dateTime = stream.dateTime.toDate().toLocaleString()
		if stream	
			<self>
				<div.streamInfo>
					<div.title> stream.title
					<div [font-weight:600]> '·'
					<div.dateTime> "Agendado para: {stream.dateTime ? stream.dateTime : '------'}"
		
				<div.buttons>
					<button @click=emit('streamSelected', index) route-to="/{user.uid}/creator/stream-manager/{streamId}">
						<svg src=play>
					<button .white @click=emit('editStream', index) route-to="/{user.uid}/creator/planned/{streamId}">
						<svg src=edit>
					<button.red>
						<svg src=deleteBtt @click=emit('deleteStream', index)>

				# if inPlanner
				# 	<button 
				# 		@click=(emit('editStream', index))
				# 		route-to="/{user.uid}/creator/planned/{streamId}"
				# 	> "Edit stream" 
				# 	<button.deleteBtt @click=emit('deleteStream', index)> 'Excluir transmissão'
				# else
				# 	<button 
				# 		@click=emit('streamSelected', index)
				# 		route-to="/{user.uid}/creator/stream-manager/{streamId}"
				# 	> "Selecionar para transmissão"