# import { textCompletion, chatCompletion } from '../../../../APIs/openAI-API.imba'

import './wiki-results.imba'
import './dict-results.imba'
import './media-results.imba'
import './translate-results.imba'
import './ai-results.imba'

const systemInstructions = {
	AI: 'Você é um assistente digital de estudos de um aluno: responda às perguntas do aluno de maneira direta e de acordo com a ciência, seja sincero sobre suas limitações como modelo de linguagem e sobre quando não possuir uma resposta adequada ou confiável para uma pergunta.'
	dict: "Você é um assistente digital de estudos de um aluno e funciona como um dicioário fornecendo definições: identifique as palavras-chave mais complexas e incomuns da frase e, por fim, responda as definições no dicionario dessas palavras. Não inclua nenhuma informação a mais e responda apenas o conteúdo no formato de objeto JSON seguindo o seguinte exemplo:
	\{
		'palavras': [
			\{
				'name': 'a palavra pesquisada',
				'definitions':[
					'definição 1',
					'definição 2',
					'definição 3'
				]
			\}
		]
	\}
	"
	translate: "Você é um assistente digital de estudos de um aluno e realiza traduções: identifique a língua utilizada e realize a tradução para português brasileiro. Não inclua nenhuma informação a mais e responda apenas o conteúdo no formato de objeto JSON seguindo o seguinte exemplo:
	\{
		'translations': [
			\{
				'prompt': 'a palavra ou frase a ser traduzida',
				'language': 'a língua em que a palavra ou frase está'
				'translation': 'a tradução para o português brasileito da palavra ou frase'
			\}
		]
	\}
	"
}

tag search-results

	prop current
	prop display = 'AI'
	prop wikiDoc
	prop dictDoc
	# prop aiMessages = []
	prop aiMessages = {
		AI: []
		dict: []
		translate: []
	}
	prop txtSearch
	prop completed = false


	def newSearch
		if txtSearch
			if display == 'dict' || display == 'translate'
				aiMessages[display] = []
			getAIResults(display)
			
	def getAIResults(type)
		await chatCompletion(aiMessages[type], txtSearch, systemInstructions[type]).then do(response)
			const {streamResponse, messages} = response
			aiMessages[type] = [
				...messages, 
				{role:'assistant', content:""}
			]
			const reader = streamResponse.body.getReader()
			readStream(reader)
		imba.commit()

	def readStream(reader)
		reader.read().then do({done, value})
			if done 
				console.log('End of stream')
				console.log(aiMessages[display])
				completed = true
				imba.commit()
				return
			completed = false
			const textChunk = new TextDecoder().decode(value)
			aiMessages[display][-1].content += textChunk
			imba.commit()
			readStream(reader)

	def aiMessagesReset
		aiMessages[display] = []
		imba.commit()

	css self bgc:#f2f2f2 h:100% w:100% d:vflex
		form d:flex p:10px ai:center jc:space-around py:0.2rem
		input 
			# w:95% mt:0.2rem rd:md bd:none 
			flg:1 p:5px
		.searchBtt bgc:#007bff c:#fff bd:none p: 5px 10px ml:10px cursor:pointer
		.mainResults of:auto p:10px
		.resultTabs d:flex jc:space-around w:100% 
			button w:25% outline:none bdb:none bw:thin bgc:warm3 rdtl:md rdtr:md
			.selected bgc:amber2

	def render
		<self>
			<form @submit.prevent=newSearch>
				<input 
					type='text' 
					placeholder='Nova pesquisa...'
					bind=txtSearch
				>
				<button.searchBtt type='submit'> 'Search'
			<div.resultTabs>
				<button type='button' .selected=(display==='AI') @click=(display='AI')>
					<span .material-symbols-outlined> 'neurology'
				# <button type='button' .selected=(display==='wiki') @click=(display='wiki')> 'Wiki'
				<button type='button' .selected=(display==='dict') @click=(display='dict')> 'Dict'
				# <button type='button' .selected=(display==='media') @click=(display='media')> 'Media'
				<button type='button' .selected=(display==='translate') @click=(display='translate')>
					<span .material-icons-outlined [fs:18px]> 'translate'
					# <span .material-icons-outlined> 'smart_toy'

			# 	# tips_and_updates
			# 	# smart_toy
			<div.mainResults>
				if !txtSearch
					<div [ta:center pt:50% o:0.4]> 'Pesquise por algo'
				else
					<ai-results type=display completed=completed prompt=txtSearch messages=aiMessages[display]
						@aiMessagesReset=aiMessagesReset
					>
					# switch display
					# 	# when 'wiki'
					# 	# 	<wiki-results doc=wikiDoc>
					# 	# when 'dict'
					# 	# 	<dict-results doc=dictDoc>
					# 	# when 'media'
					# 	# 	<media-results doc=wikiDoc>
					# 	# when 'translate'
					# 	# 	<translate-results txt=txtSearch>

				