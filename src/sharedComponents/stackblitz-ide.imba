import sdk from '@stackblitz/sdk'

import { collection, doc, updateDoc, setDoc, onSnapshot, getDoc, query, orderBy, where, serverTimestamp} from 'firebase/firestore'

import { firestoreDB } from '../firebase.imba'

# import { javascriptProject } from './stackblitz-template.imba'

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

tag stackblitz-ide

	prop streamer = false
	prop vm
	prop filesSnapshot
	prop interval
	prop embedOptions = {
		# height: 400,
		# openFile: 'index.js',
		terminalHeight: 50,
		# height:600
	}
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

	def mount
		embedProject()

	def unmount
		clearInterval(interval)

	def embedProject
		console.log projectData
		vm = await sdk.embedProject($embed, projectData, embedOptions)
		if streamer && vm
			interval = setInterval(&, 2000) do()
				getSnapshot()

	def getSnapshot
		projectData.files = await vm.getFsSnapshot()
		projectData.dependencies = await vm.getDependencies()
		sendChanges()

	def applyChanges
		const destroy = []
		const currentSnapshot = await vm.getFsSnapshot()
		filesSnapshot = projectData.files
		for own fileName, text of currentSnapshot
			console.log fileName
			if filesSnapshot[fileName] === undefined
				destroy.push(fileName)

		vm.applyFsDiff({
			create: filesSnapshot
			destroy
		})

	def sendChanges
		if streamer
			emit('ideUpdate', projectData)

	css self
			w:100% h:100%
		.embed
			w:100% h:100%
	def render
		<self>
			
			# <select bind=projectData.template @change=handleTemplateChange>
			# 	for own template, files of templatesFiles
			# 		<option value=template selected=(template=='javascript')> template
			# <button @click=embedProject> 'get IDE'

			if !streamer
				<button @click=applyChanges> 'update'

			<div$embed .embed>