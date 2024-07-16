import { addDoc, collection, doc, setDoc, updateDoc, deleteDoc, onSnapshot, query, where, orderBy, serverTimestamp } from 'firebase/firestore'
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage'
import { nanoid } from 'nanoid'

import { auth, storage } from '../../../../firebase.imba'

import "../stream-planner.imba"

tag video-adder

	prop user
	prop videoFile\File
	prop fileUrl
	prop description=''
	prop editing
	prop tempUrl
	prop videoElement
	prop fileName

	def resetData
		videoFile=null
		description=''
		fileUrl=''
		tempUrl=''
		videoElement.src=null
		fileName=''
		$input.value=null

	def insertVideo(e)
		videoFile = e.target.files[0]
		fileName = e.target.value.split('\\').pop()
		console.log fileName
		tempUrl = URL.createObjectURL(videoFile)
		videoElement.src=tempUrl
		# $video.setAttribute('src', tempUrl)
		imba.commit()

	def uploadVideo
		fileRef = ref(storage, "users/{user.uid}/streamsContent/videoFiles/{fileName}")
		await uploadBytes(fileRef, pdfFile).then do(res)
			console.log 'file uploaded'
		await getDownloadURL(fileRef).then do(url)
			fileUrl = url
			console.log fileUrl

	def handleSubmit(e)
		const contentData = {
			contentType : 'video'
			fileUrl
			description
			contentId: nanoid()
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		description = ''
		videoFile = null
		e.target.reset()

	def unmount
		resetData()

	css self
			w:100% h:100%
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

	def render
		if editing!== null && typeof(editing)=='object'
			fileUrl = editing.contentData.fileUrl
			videoElement.setAttribute('src', fileUrl)
			editing=true

		css self h:100%
			form d:vflex h:100%

		<self>
			<form 
			@submit=handleSubmit
			@reset=resetData>
				<div.title> "Adicionar arquivo de vídeo"
				
				<input$input type='file' accept='video/*' @change=insertVideo required>
				# <input type='text' bind=description>
				<submit-btt editing=editing>
