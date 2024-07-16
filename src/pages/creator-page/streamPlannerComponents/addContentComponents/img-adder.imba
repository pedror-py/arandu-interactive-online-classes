import { addDoc, collection, doc, setDoc, updateDoc, deleteDoc, onSnapshot, query, where, orderBy, serverTimestamp } from 'firebase/firestore'
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage'
import { nanoid } from 'nanoid'

import { auth, storage } from '../../../../firebase.imba'

import '../stream-planner.imba'

tag img-adder

	prop user
	prop imgFile\File
	prop editing
	prop fileRef
	prop fileUrl
	prop fileName

	def insertImg(e)
		imgFile = e.target.files[0]
		fileName = e.target.value.split('\\').pop()
		console.log fileName
		const tempUrl = URL.createObjectURL(imgFile)
		$img.setAttribute('src', tempUrl)
		imba.commit()

	def uploadImg
		fileRef = ref(storage, "users/{user.uid}/streamsContent/imgFiles/{fileName}")
		await uploadBytes(fileRef, imgFile).then do(res)
			console.log 'file uploaded'
		await getDownloadURL(fileRef).then do(url)
			fileUrl = url
			console.log fileUrl

	def resetData(e)
		imgFile = null
		$input.value = null
		fileRef = null
		fileUrl = null

	def handleSubmit(e)
		await uploadImg()
		const contentData = {
			contentType : 'img'
			# storageRef : fileRef
			filePath: fileRef.path
			fileUrl
			contentId: nanoid()
		}
		if editing
			emit('updateContent', contentData)
			editing= null
		else
			emit('addContent', contentData)
		resetData(e)
	
	css self h:100%
		form d:vflex h:80%
		iframe h:100%


	def render
		if editing!== null && typeof(editing)=='object'
			fileUrl = editing.contentData.fileUrl
			$img.setAttribute('src', fileUrl)
			editing=true
		<self>
			<form
			@submit.prevent=handleSubmit
			@reset=resetData
			>
				<h5 [m:5px]> "Adicionar uma imagem"
				<label>
					<input$input type='file' accept="image/*" @change=insertImg required>
				if imgFile || fileUrl
					<img$img width="500" height="500">

				<submit-btt editing=editing>