import { nanoid } from 'nanoid'

const slideTest = "https://docs.google.com/presentation/d/e/2PACX-1vS2kvCGoVLzpkpkvZ7ij2ROdr9TFclUOXDwLUgC1sNIZn54sjgCAg5rGGuSxkscoXkEa_Pa_gm9kkHP/embed?start=false&loop=false&delayms=3000"

def extractSrc(htmlString)
	const parser = new DOMParser()
	let iframe
	try
		let doc = parser.parseFromString(htmlString, 'text/html')
		iframe = doc.querySelector('iframe')
	return iframe ? iframe.getAttribute('src') : htmlString

tag slides-adder

	prop editing
	prop slideUrl
	prop slideType
	prop streamData
	prop continueSlide = false
	prop hasSlide = false
	prop iframe

	def handleSubmit
		const contentData = {
			contentType: 'slide'
			slideType
			slideUrl
			continueSlide
			contentId: nanoid()
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		resetData()

	def handleInput
		if slideUrl.includes('iframe')
			slideUrl = extractSrc(slideUrl)
		if slideUrl.includes('google')
			slideType = 'google'
			slideUrl = slideUrl.replace("embed?", "pub?")
		# else slideType = 'powerPoint'
		iframe.src = slideUrl
		imba.commit()


	def resetData
		slideUrl=''
		hasSlide = false
		continueSlide = false

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
			slideUrl = editing.contentData.slideUrl
			iframe.src = slideUrl
			editing = true

		if streamData
			for contentData, i of streamData.contentsData
				if contentData.contentType === 'slide'
					hasSlide = true
					if continueSlide
						{ slideUrl, slideType } = streamData.contentsData[i]

		<self>
			<form
				@submit.prevent=handleSubmit
				@reset=resetData
			>
				<div.title> "Adicionar apresentação de slides"
				# <div>
				# 	if hasSlide
				# 		<button type='button' @click=(continueSlide = !continueSlide)> 'Continuar dos slides anteriores'

				# <label> "Cole a URL dos slides"
				# 	<input type='text' bind=slideUrl @input=handleInput required>
				<input-arandu type='text' label="Cole a URL dos slides"
				bind:value=slideUrl 
				@input=handleInput
				required=true
				>
				# if slideURL
				# <iframe src=slideUrl frameborder="0" width="480" height="299" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true">
				if continueSlide
					<div> 'Os slides irão continuar de onde você parou'
				<submit-btt editing=editing>




# https://docs.google.com/presentation/d/e/2PACX-1vS2kvCGoVLzpkpkvZ7ij2ROdr9TFclUOXDwLUgC1sNIZn54sjgCAg5rGGuSxkscoXkEa_Pa_gm9kkHP/pub?start=false&loop=false&delayms=3000

# <iframe src="https://docs.google.com/presentation/d/e/2PACX-1vS2kvCGoVLzpkpkvZ7ij2ROdr9TFclUOXDwLUgC1sNIZn54sjgCAg5rGGuSxkscoXkEa_Pa_gm9kkHP/embed?start=false&loop=false&delayms=3000" frameborder="0" width="960" height="569" allowfullscreen="true" mozallowfullscreen="true" webkitallowfullscreen="true"></iframe>