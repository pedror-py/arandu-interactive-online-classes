import { addDoc, collection, doc, setDoc, updateDoc, deleteDoc, onSnapshot, query, where, orderBy, serverTimestamp } from 'firebase/firestore'
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage'
import { nanoid } from 'nanoid'

import { auth, storage } from '../../../../firebase.imba'

import '../stream-planner.imba'

tag pdf-adder

	prop user
	prop pdfFile\File
	prop editing
	prop fileRef
	prop fileUrl
	prop fileName
	prop iframe
	prop storagePath

	def insertPdf(e)
		pdfFile = e.target.files[0]
		fileName = e.target.value.split('\\').pop()
		console.log fileName
		const tempUrl = URL.createObjectURL(pdfFile)
		# $iframe.setAttribute('src', tempUrl)
		iframe.src = tempUrl
		imba.commit()

	def uploadPdf
		storagePath = "users/{user.uid}/streamsContent/pdfFiles/{fileName}"
		fileRef = ref(storage, storagePath)
		await uploadBytes(fileRef, pdfFile).then do(res)
			console.log 'file uploaded'
		await getDownloadURL(fileRef).then do(url)
			fileUrl = url
			console.log fileUrl

	def resetData(e)
		pdfFile = null
		$input.value = null
		fileRef = null
		fileUrl = null
		editing=null
		storagePath = null
		# iframe.src=''

	def handleSubmit(e)
		await uploadPdf()
		const contentData = {
			contentType : 'pdf'
			storagePath,
			# filePath: fileRef.path
			fileUrl
			contentId: nanoid()
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		resetData(e)
	
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
		# iframe h:100%


	def render
		if editing!== null && typeof(editing)=='object'
			fileUrl = editing.contentData.fileUrl
			iframe.src = fileUrl
			editing=true

		<self>
			<form
			@submit.prevent=handleSubmit
			@reset=resetData
			>
				<div.title> "Adicionar arquivo PDF"
				<label>
					<input$input type='file' accept='.pdf' @change=insertPdf required>

				<submit-btt>