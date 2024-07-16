import { addDoc, collection, doc, setDoc, updateDoc, deleteDoc, onSnapshot, query, where, orderBy, serverTimestamp } from 'firebase/firestore'
import { nanoid } from 'nanoid'

import { firestoreDB } from '../../../../firebase.imba'

import '../stream-planner.imba'
import '../../../../sharedComponents/stackblitz-ide.imba'

const templatesFiles = {
	'angular-cli':{
		'index.html': ''
		'main.ts': ''
	}
	'create-react-app'	:{
		'index.html': ''
		'index.js': ''
	}
	'html':{
		'index.html': ''
	}
	'javascript':{
		'index.html': ''
		'index.js': ''
	}
	'polymer':{
		'index.html': ''
	}
	'typescript':{
		'index.html': ''
		'index.ts': ''
	}
	'vue':{
		'public/index.html': ''
		'src/main.ts': ''
	}
	'node':{}
}

const options = [
	'angular-cli'
	'create-react-app'
	'html'
	'javascript'
	'polymer'
	'typescript'
	'vue'
	'node'
]

tag code-editor-adder

	prop editing = null
	prop showIde = false
	prop projectData = {
		title: ''
		description: ''
		template: 'javascript'
		files: {
			'index.html':''
			'index.js':''
		}
		settings: {
			compile: {
				clearConsole: false
			}
		}
		dependencies: {}
	}
	
	def handleTemplateChange
		projectData.files = templatesFiles[projectData.template]
		emit('templateChange', projectData)

	def handleSubmit
		const contentData = {
			contentType : 'codeEditor'
			projectData
			contentId: nanoid()
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		resetData()

	def resetData
		projectData.title = ''
		projectData.template = 'javascript'

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
			fileUrl = editing.contentData.fileUrl
			$iframe.setAttribute('src', fileUrl)
			editing=true
		<self>
			<form
			@submit.prevent=handleSubmit
			@reset=resetData
			>
				<div.title> "Adicionar IDE (editor de código)"
				<input-arandu label="Título" type='text' bind:value=projectData.title>
				# <label> 'Título'
				# 	<input$input type='text' bind=projectData.title>

				<select-arandu label='Template' bind:value=projectData.template options=options @change.log('templateChange')=handleTemplateChange>
				# <label> 'Escolha o template'
				# <select bind=projectData.template @change=handleTemplateChange >
				# 	for own template, files of templatesFiles
				# 		<option value=template selected=(template=='javascript')> template

				# <button type='button' @click=(showIde=!showIde)> 'preview da IDE'
				# if showIde
				# 	<stackblitz-ide projectData=projectData streamer=true @ideUpdate=(projectData=projectData)>

				<submit-btt>
