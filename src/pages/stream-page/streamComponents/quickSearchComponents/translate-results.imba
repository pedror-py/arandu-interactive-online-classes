
const urlAPI = "https://libretranslate.com/translate"

tag translate-results

	prop txt = 'book'
	prop translated = ''
	prop sourceLang = 'en'
	prop targetLang = 'pt'

	def getTranslation
		const options = {
			method: "POST",
			headers: { "Content-Type": "application/json" }
			body: JSON.stringify({
				q: txt
				source: sourceLang
				target: targetLang
				format: "text"
				api_key: ""
			})
		}
		const res = await window.fetch(urlAPI, options)
		console.log(await res.json())

	def render
		<self>
			<form @submit.prevent=getTranslation>
				<input type='text' contentsData=txt>

			<div>
				<p> translated