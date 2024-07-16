
tag ai-results

	prop type
	prop prompt
	prop messages = []
	prop completed

	css self
		.userMessage bgc:#007bff c:#fff p:8px rd:5px ta:right mb:10px
		.assistantMessage bgc:#eaeaea p:8px rd:5x mb:10px

	def render
		console.log completed
		<self>
			if messages.length > 0
				for message of messages
					if message.role === 'user' && type == 'AI'
						<div.userMessage> message.content
					if message.role === 'assistant'
						# <div [fs:12px]> 'IA:'
						if type == 'dict'
							if completed
								console.log message.content
								let dictResult = JSON.parse(message.content)
								console.log dictResult
								<div.assistantMessage>
									for palavra of dictResult.palavras
										<h5> palavra.name
										<ol>
											for definition of palavra.definitions
												<li> definition
						if type == 'translate'
							if completed
								console.log message.content
								let translateResult = JSON.parse(message.content)
								console.log translateResult
								<div.assistantMessage>
									for translation of translateResult.translations
										<h5> translation.prompt
										<h6> "traduzido do {translation.language}"
										<p> translation.translation
						if type == 'AI'
							<div.assistantMessage> message.content
							# message.content

				<button @click=emit('aiMessagesReset')> 'Limpar'

