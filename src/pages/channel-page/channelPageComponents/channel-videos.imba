import { collection, doc, setDoc, updateDoc, addDoc, getDocs, getDoc, deleteDoc, onSnapshot, query, where, orderBy, limit, serverTimestamp } from 'firebase/firestore'

import { ref, getDownloadURL, getBlob } from "firebase/storage"

import { firestoreDB, storage } from '../../../firebase.imba'

tag channel-videos

	prop user
	prop channelId
	prop channelDocRef
	prop channelDoc
	prop channelData
	prop videoDocs = []

	def awaken
		getVideoDocs()

	def getVideoDocs
		const ownerId = channelData.ownerId
		const q = query(collection(firestoreDB, 'streams'),
			where('userId', '==', ownerId),
			where('streamed', '==', true),
			# orderBy('createdAt', 'desc'),
			limit(20)
		)
		await getDocs(q).then do(docs)
			for doc in docs.docs
				videoDocs.push(doc)
		imba.commit()


	<self>
		for doc of videoDocs
			<div> doc.id
			const data = doc.data()
			<video-item videoData=data>

		

tag video-item

	prop videoData
	prop videoUrl
	prop blob

	def awaken
		blob = await getBlob(ref(storage, videoData.storagePath))
		console.log blob
		$video.src = URL.createObjectURL(blob)
		# videoUrl = url
		# console.log videoUrl
		# const xhr = new XMLHttpRequest()
		# xhr.responseType = 'blob'
		# xhr.onload = do(event) 
		# 	const blob = xhr.response
			
		# xhr.open('GET', url)
		# xhr.send()


	<self [d:flex]>
		<video$video [w:50%] srcObject=blob playsinline controls>