import { addDoc, collection, doc, setDoc, getDoc, updateDoc, deleteDoc, onSnapshot, query, where, orderBy, serverTimestamp } from 'firebase/firestore'

# import "./add-content-pannel.imba"
# import "./multimidia-planner.imba"
# import "./stream-timeline.imba"

import play from '../../../assets/icons/play-button-icon.svg'
import edit from '../../../assets/icons/edit-button-icon.svg'

import { firestoreDB } from '../../../firebase.imba'

# preparar a stream didática com midias e tópicos já inseridos
tag stream-planner

	prop user
	prop popUp
	prop displayContentType = ''
	prop contentToEdit\object = null
	prop streamsRef  # reference to collection of user streams (no stream data, only references)
	prop plannedStreams = []
	prop editingStream = null
	prop streamData = {
		streamType: null
		streamed:false
		title:''
		tags:[]
		category:''
		dateTime:null
		contentsData: []  # lista de objetos com info de cada conteúdo
	}
	prop iframe

	# def mount
	# 	# if !streamData
	# 	# 	suspend()
	# 	# 	console.log router.path
	# 	# 	console.log router.path.plit('planned/')[1]
	# 	if editingStream === null
	# 		resetValues()
			
	def unmount
		resetValues()

	def resetValues
		streamData = {
			streamType: null
			streamed:false
			title:''
			tags:[]
			category:''
			dateTime:null
			contentsData: []
		}

	def getData
		const id = router.path.split('planned/')[1]
		if id === 'new'
			resetValues()
		for element, i in plannedStreams
			if element.id === router.path.split('planned/')[1]
				streamData = element.data()
		imba.commit()


	def newContent(e)
		if iframe && iframe.src
			iframe.src = ''
		displayContentType=''
		imba.commit()
		displayContentType=e.detail
		contentToEdit = null
		popUp=''
		imba.commit()

	def addContent(e)
		streamData.contentsData.push(e.detail)
		displayContentType = ''
		imba.commit()

	def editContent(e)
		const index = e.detail
		# displayContentType = ''
		# imba.commit()

		if contentToEdit
			if contentToEdit.index == index
				displayContentType = ''
				contentToEdit = null
				return

		const contentData = streamData.contentsData[index]
		displayContentType = contentData.contentType
		contentToEdit = {
			index
			contentData
		}
		imba.commit()
	
	def updateContent(e)
		const index = contentToEdit.index
		const updatedContent = e.detail
		streamData.contentsData[index] = updatedContent
		contentToEdit = null
		displayContentType = ''
		imba.commit()

	def deleteContent(e)
		const index = e.detail
		streamData.contentsData.splice(index, 1)
		if contentToEdit && contentToEdit.index == index
			displayContentType = ''
	
	def removeFile

	def updateStreamData(e)
		let {title, tags, category, dateTime} = e.detail
		streamData = {...streamData, title, tags, category, dateTime}
		popUp = ''
		# salvarStream()

	def salvarStream
		if editingStream !== null
			const ref = plannedStreams[editingStream].ref
			streamData = {...streamData, lastEdited:serverTimestamp()}
			# await setDoc(ref, streamData)
			editingStream = null
			emit('saveEditedStream', {ref, data:streamData})
		else
			streamData = {
				...streamData
				userId: user.uid
				createdAt: serverTimestamp()
			}
			emit('newStream', streamData)

			# # add doc to streams collection at root (contains streamData)
			# streamData = {
			# 	...streamData
			# 	userId: user.uid
			# 	createdAt: serverTimestamp()
			# }
			# const docRef = await addDoc(collection(firestoreDB, "streams"), streamData)

			# # add doc to streams collection inside user doc with reference
			# const streamUserRef = {
			# 	userId: user.uid
			# 	streamId: docRef.id
			# 	streamDocPath: docRef.path
			# 	streamed:streamData.streamed
			# 	dateTime:streamData.dateTime
			# 	lastEdited:serverTimestamp()
			# }
			# const path = streamsRef.path + "/{docRef.id}"
			# setDoc(doc(firestoreDB, path), streamUserRef)
		# route-to="/{user.uid}/creator/selection/plan"
		# emit('saved')

	css self 
			font-family: Poppins
			w:100% h:100% bg:#171419
			display: vflex;
			jc:flex-start
			flex-shrink: 0;

		.contentPreviewContainer
		.timelineContainer
			w:100%
			h:13rem
			mt:auto
			flex-shrink: 0
			box-shadow: 0px -4px 9px 0px rgba(0, 0, 0, 0.10);

	def render
		if !streamData
			getData()
		else
			<self
				# content pannel events
				@addContent=addContent
				@newContent=newContent
				@updateContent=updateContent
				@cancelEdit=(displayContentType='', contentToEdit=null)

				# timeline events
				@deleteContent=deleteContent
				@editContent=editContent

				# stream
				@salvarStream=salvarStream
				@limpar=(streamData.contentsData=[])
				# @voltar=voltar

				@popup=(popUp=e.detail)
				@closeModal=(popUp='')
				@iframe=(iframe=e.detail)
			>
				<StreamInfo streamData=streamData>
				<ContentPreview bind:streamData=streamData user=user displayContentType=displayContentType contentToEdit=contentToEdit>
				<div.timelineContainer>
					<stream-timeline bind:contentsData=streamData.contentsData contentToEdit=contentToEdit currentIndex=(contentToEdit && contentToEdit.index) user=user>
				if popUp === 'editStreamData'
					<edit-stream-data @closeModal=(popUp='') @updateStreamData=updateStreamData  data=streamData>
				if popUp === 'newContent'
					<add-content-pannel>

tag ContentPreview

	prop streamData 
	prop contentToEdit 
	prop displayContentType
	prop user
	prop iframe

	css self
			h:100% px:2rem
			d:flex ai:center jc:space-between 
		.preview
			pos:relative
			# l:50%
			# x:-50%
			# w:45%
			h:95%
			aspect-ratio: 16 / 9
			background: #000000
		iframe, img, video, stackblitz-ide
			w:100% h:100%
		.details
			h:90% w:50%
		.text
			pos:absolute
			l:50% x:-50%
			t:50% y:-50%
			fs:0.8rem
			o:0.5

	def render
		let editorData
		switch displayContentType
			when ''
				if iframe && iframe.src
					iframe.src = ''	
			when 'img'
				iframe=$img
			when 'video'
				iframe=$video
			else
				iframe=$iframe
		emit('iframe', iframe)

		<self @templateChange=(editorData=e.detail)>
			<div.details>
				<multimidia-planner
				iframe=iframe
				bind:streamData=streamData 
				contentToEdit=contentToEdit 
				displayContentType=displayContentType
				user=user
				>
			<div.preview>
				switch displayContentType
					when ''
						<div.text> 'nenhum conteúdo selecionado'
					when 'img'
						<img$img>
					when 'video'
						<video$video controls>
					# when 'quiz'
					# 	iframe=$quiz
					# 	<quiz$quiz>
					when 'editor'
						<stackblitz-ide$ide streamer=true projectData=editorData>
					else
						<iframe$iframe>


tag StreamInfo

	prop streamData


	css self
			box-sizing: border-box
			display: flex;
			width:100%;
			height: 2.5rem;
			padding: 0.5rem 1rem;
			background: #2A2A2A;
			flex-shrink: 0;
		.info
			w:100%
			display: flex;
			align-items: center;
			gap: 2rem;
		.container
			display: flex;
			align-items: flex-start;
			gap: 0.5rem;
			fs:0.75rem
		.buttons
			ml:auto
			display: flex;
			justify-content: flex-end;
			align-items: center;
			gap: 0.5rem;
		.play
			bg:none bd:none
			d:flex
		.edit
			font-family:Poppins
			fs:0.7rem
			c:white
			display: flex;
			bd:none
			padding: 0.25rem 0.5rem;
			align-items: flex-end;
			gap: 0.5rem;
			border-radius: 0.25rem;
			background: #535353;
	<self>
		<div.info> 
			<div.container> 
				<div> 'Título:'
				<div> streamData.title ? streamData.title : '-----'
			<div.container> 
				<div> 'Categoria:'
				<div> streamData.category ? streamData.category : '-----'
			<div.buttons>
				<button.edit @click=emit('popup', 'editStreamData')>
					<svg fill='white' src=edit>
					<div> 'Editar dados de transmissão'
				<button.play description='iniciar transmissão'>
					<svg src=play>


tag submit-btt
	prop editing
	prop disabled = false

	css self 
			mt:auto
		.container
			d:flex

	<self>
		<div.container>
			# <button [mr:auto] type='reset'> "Limpar dados" 
			if editing
				<button type='reset' disabled=disabled @click=emit('cancelEdit')> 'Cancelar'
				<button type="submit" disabled=disabled @click=emit('submited')> "Salvar alterações"
			if !editing
				<button.button-arandu type="submit" disabled=disabled> "Adicionar conteúdo na transmissão"
				# <button-arandu [w:16rem h:2rem] text="Inserir na timeline da stream" type="submit" disabled=disabled> 


tag stream-type-selection

	prop streamTypes = [
		{
			type: 'multimidia'
			title: 'Multimidia'
			description:['aaaaaaa', 'bbbbb', 'ccccc']
		}
		{
			type: 'monitoria'
			title: 'Monitoria'
			description:['aaaaaaa', 'bbbbb', 'ccccc']
		}
		{
			type: 'programming'
			title: 'Programação'
			description:['aaaaaaa', 'bbbbb', 'ccccc']
		}
		]

	css self
		.container d:flex g:50px

	<self>
		# <button @click=emit('voltar')> "cancelar e voltar"
		<div.container>
			for type of streamTypes
				<stream-type-card data=type>


tag stream-type-card

	prop data

	css self
		w:200px h:400px bd:1px solid black d:vflex ai:center rd:lg
		.img mt:20px

	<self @click=emit('typeSelected', data.type)>
		<div.img [s:170px bgc:blue4]>
		<div> data.title
		<ul [as:flex-start]>
			for topic of data.description
				<li> topic


# css self h:100%
# 	main h:100% w:100% d:flex jc:space-between
# 	section w:55%
# 	.streamInfo bgc:gray4 h:15% d:vflex
# 	.contentDetails flg:1 h:85%
# 	.timelineContainer h:90%
# 	.plannerBtns d:vflex h:10%
# 	.editData ml:auto
# 	.popUp bgc:blue4 rd:20px shadow:xl bd:blue5 h:60% w:40%
# 		pos:absolute l:50% x:-50% t:50% y:-50%
# 	.popUpBackground h:100vh w:100vw pos:absolute bgc:hsla(0,0%,0%,0.7) l:50% x:-50% t:50% y:-50%

# def render
# 	if !streamData
# 		getData()
# 	else
# 		<self
# 			# content pannel events
# 			@addContent=addContent
# 			@newContent=newContent
# 			@updateContent=updateContent
# 			@cancelEdit=(displayContentType='', contentToEdit=null)

# 			# timeline events
# 			@deleteContent=deleteContent
# 			@editContent=editContent

# 			# stream
# 			@salvarStream=salvarStream
# 			@limpar=(streamData.contentsData=[])
# 			# @voltar=voltar

# 			@popup=(popUp=e.detail)
# 		>
# 				<main.planner>
# 					<div.contentConfig>
# 						# <button @click=emit('voltar')> "cancelar e voltar"
# 						<add-content-pannel displayContentType=displayContentType>
# 						<hr [mt:0.1em]>
# 					<section>
# 						<div .streamInfo>
# 							<div> "Título: {streamData.title}"
# 							<div> "Categoria: {streamData.category}"
# 							<div.tags [d:flex g:5px]>
# 								for streamTag of streamData.tags
# 									<div> "#{streamTag}"
# 							<div> "Horário: {streamData.dateTime}"
# 							<button .editData @click=emit('popup', 'editStreamData')> "Editar dados da transmissão"
# 						<div.contentDetails >
# 							<multimidia-planner 
# 							streamData=streamData 
# 							contentToEdit=contentToEdit 
# 							displayContentType=displayContentType
# 							user=user
# 							>
# 					<div.timelineContainer>
# 						<stream-timeline contentsData=streamData.contentsData>
# 						<div.plannerBtns>
# 							<button 
# 								@click=(emit('salvarStream'))
# 								route-to="/{user.uid}/creator/selection/plan"
# 							> "Finalizar e salvar stream"
# 							<button type='button' @click=emit('limpar')> "Limpar dados da stream"
# 				if popUp
# 					<div.popUpBackground>
# 					<div.popUp> 
# 						<global  @pointerdown.outside=(popUp='')>
# 						if popUp === 'editStreamData'
# 							<edit-stream-data 	
# 								@closePopUp=(popUp='') 
# 								@updateStreamData=updateStreamData 
# 								useDatetime=true
# 								bind=(do({title, tags, category, dateTime})
# 									({title, tags, category, dateTime}))(streamData)
# 							> 