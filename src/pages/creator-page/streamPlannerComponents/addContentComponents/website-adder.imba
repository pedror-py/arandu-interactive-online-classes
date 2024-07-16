
import '../stream-planner.imba'

tag website-adder

	prop data
	prop iframe
	prop user
	prop websiteUrl
	prop editing
	prop loading = false

	def getWebsite()
		loading=true
		iframe.src = websiteUrl
		imba.commit()
	
	def resetData()
		websiteUrl = ''

	def handleSubmit()
		const contentData = {
			contentType : 'website'
			websiteUrl
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
			h:100%
		form 
			d:vflex h:100% w:100%
		.title
			color: var(--principal-branco, #FFF);
			font-family: Poppins;
			font-size: 1.2rem;
			font-style: normal;
			font-weight: 500;
			line-height: 150%;
			mb:1rem

	def render
		if editing!== null && typeof(editing)=='object'
			websiteUrl = editing.contentData.websiteUrl
			editing=true
			getWebsite()

		<self>
			<form
			@submit.prevent=handleSubmit
			@reset=resetData
			>
				<div.title> "Adicionar uma página de website"
				<div.input-container>
					<label.input-label> "Insira a URL do video do YouTube"
					<input$websiteUrl .input-arandu
						# placeholder='URL do Youtube'
						type='url'
						name='websiteUrl'
						required=true
						bind=websiteUrl
						@input=getWebsite
					>
				# <input-arandu type='text' label='Insira o endereço do site:'
				# bind:value=websiteUrl 
				# @input=getWebsite
				# >
				
				<submit-btt editing=editing>




# tag website-adder

# 	prop iframe
# 	prop user
# 	prop websiteUrl
# 	prop editing
# 	prop loading = false

# 	def unmount
# 		loading = false
# 		editing = null

# 	def getWebsite()
# 		loading=true
# 		imba.commit()
# 		iframe.src = websiteUrl
	
# 	def resetData()
# 		websiteUrl = null
# 		iframe.src = null

# 	def handleSubmit()
# 		const contentData = {
# 			contentType : 'website'
# 			websiteUrl
# 		}
# 		if editing
# 			emit('updateContent', contentData)
# 			editing= null
# 		else
# 			emit('addContent', contentData)
# 		resetData()

# 	css self 
# 			h:100%
# 		form 
# 			d:vflex h:100% w:100% g:2rem

# 	def render
# 		if editing!== null && typeof(editing)=='object'
# 			websiteUrl = editing.contentData.websiteUrl
# 			editing=true
# 			getWebsite()

# 		<self>
# 			<form
# 			@submit.prevent=handleSubmit
# 			@reset=resetData
# 			>
# 				<div> "Adicionar uma página de website"
# 				<input-arandu type='text' label='Insira o endereço do site:'
# 				bind:value=websiteUrl 
# 				@input=getWebsite
# 				>
				
# 				# <submit-btt editing=editing>