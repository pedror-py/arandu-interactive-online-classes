# https://www.youtube.com/embed/WmR9IMUD_CY?start={startAt}
# https://www.youtube.com/watch?v=WmR9IMUD_CY&list=PLSNxYnJUpc0nJ-HmK3RoRwSiM7EjUBluk&index=2&ab_channel=Fireship

import "../stream-planner.imba"
import "../../../../sharedComponents/loading-animation.imba"

const videoWidth = 560
const videoHeight = 315

tag yt-video-adder

	prop videoUrl = ''
	prop videoId = ''
	prop startAt\number = 0
	prop editing = null
	prop loading = false
	prop iframe

	def mount
		if editing === true
			resetData()
		if editing!== null && typeof(editing)=='object'
			videoUrl= editing.contentData.videoUrl
			videoId = editing.contentData.videoId
			startAt = editing.contentData.startAt
			iframe.src = "https://www.youtube.com/embed/{videoId}?start={startAt}"
			# $startAt.value = editing.contentData.startAt
			# $videoUrl.value= editing.contentData.videoUrl
			editing=true

	def urlHandler
		loading = true
		# videoId = ''
		imba.commit()
		let regExp = /^.*(youtu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
		if videoUrl
			let match = videoUrl.match(regExp)
			if match && match[2].length == 11
				videoId = match[2]
				iframe.src = "https://www.youtube.com/embed/{videoId}?start={startAt}"
			else
				console.log "error at extracting video ID"
		imba.commit()

	def resetData
		videoUrl = ''
		videoId = ''
		startAt\number = null
		editing=null

	def handleSubmit(e)
		const contentData = {
			contentType: 'YT'
			videoUrl
			videoId
			startAt
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		resetData()

	def unmount
		resetData()

	css self 
			h:100%	w:100%
		form 
			d:vflex h:100%
		.title
			color: var(--principal-branco, #FFF);
			font-family: Poppins;
			font-size: 1.2rem;
			font-style: normal;
			font-weight: 500;
			line-height: 150%;
			mb:1rem
		label
			all:unset
			align-self: stretch;
			color: var(--principal-branco);
			font-family: Poppins;
			font-size: 0.7em;
			opacity: 0.8;
		.box
			ml:auto mt:0.5rem
		.startAt 
			bd:none
			min-width:30px
			max-width:50px
			box-sizing: border-box
			padding:0.1rem 0.2rem;
			border-radius: 0.2rem;
			background: var(--ui-text-input, #413947);
			color:rgba(225,225,225, 0.5)
			font-family: Poppins;
			font-size: 0.7rem;
			color: var(--principal-branco)
		input[type="number"]::-webkit-inner-spin-button, input[type="number"]::-webkit-outer-spin-button
			-webkit-appearance: none;
			margin: 0;
			

	def render
		# if editing!== null && typeof(editing)=='object'
		# 	videoUrl= editing.contentData.videoUrl
		# 	videoId = editing.contentData.videoId
		# 	startAt = editing.contentData.startAt
		# 	iframe.src = "https://www.youtube.com/embed/{videoId}?start={startAt}"
		# 	$startAt.value = editing.contentData.startAt
		# 	$videoUrl.value= editing.contentData.videoUrl
		# 	editing=true
		<self>
			<form 
				@submit.prevent=handleSubmit
				@reset=resetData
			>
				<div.title> "Adicionar vídeo do YouTube"
				<div.input-container>
					<label.input-label> "Insira a URL do video do YouTube"
					<input$videoUrl .input-arandu
						placeholder='URL do Youtube'
						type='url'
						name='videoUrl'
						required=true
						bind=videoUrl
						@input=urlHandler
					>
				# <input-arandu 
				# 	label="Insira a URL do video do YouTube" 
				# 	type='url'
				# 	placeholder='URL do Youtube'
				# 	required=true
				# 	name='videoUrl'
				# 	bind:value=videoUrl
				# 	@input=urlHandler 
				# >
				<div.box>
					<label> "Início: "
					<input$startAt .startAt 
					type='number' name="startAt" min='0'
					bind=startAt @input=urlHandler>
					<label> ' segundos'
				# <div.preview>
				# 	if videoUrl && videoId
				# 		if loading
				# 			<loading-animation>
				# 		<iframe @load=(loading=false) width=videoWidth height=videoHeight src="https://www.youtube.com/embed/{videoId}?start={startAt}" title="YouTube video player" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allow='fullscreen'>
				<submit-btt editing=editing>
	