
import { collection, doc, setDoc, updateDoc, addDoc, getDocs, getDoc, deleteDoc, onSnapshot, query, where, orderBy, limit, serverTimestamp } from 'firebase/firestore'
import { ref, getDownloadURL, getBlob } from "firebase/storage"

import { storage } from '../../../firebase.imba'

import '../creatorPageComponents/planned-streams.imba'

tag creator-contents

	prop user
	prop userDoc
	prop streamsRef
	prop plannedStreams
	prop finishedStreams = []

	# def editStream
	# 	route-to=

	def awaken
		const q = query(streamsRef, 
			where('streamed', '==', true), 
			# orderBy('createdAt', 'desc'), 
			# limit(10)
		)
		await getDocs(q).then do(docs)
			docs.forEach(do(doc) 
				finishedStreams.push(doc)
			)
			imba.commit()

		# console.log finishedStreams[0].data()



	<self>
		<div> 'Transmissões planejadas'
		<div [d:flex]> 
			for stream, i of plannedStreams
				<planned-stream-item stream=stream.data() index=i inPlanner=!false>

		<div> 'Transmissões feitas'
			for doc of finishedStreams
				const videoData = doc.data()
				<video-registry videoDoc=doc streamId=streamId>
				# <div> data.streamId

tag video-registry

	prop videoDoc
	prop videoUrl
	prop streamId

	def awake
		videoData = videoDoc.data()
		# console.log videoData
		

	def render
		videoData = videoDoc.data()
		console.log videoData.storagePath
		if !videoUrl
			const videoRef = ref(storage, videoData.storagePath)
			await getDownloadURL(videoRef).then do(url)
				videoUrl = url
				imba.commit()

		<self>
			<div.container [d:flex]>
				<details>
					<summary> "Título: {videoData.title}"
					<div.id> "video id: {videoDoc.id}"
					<div.streamedAt>
					<div.link>
					<a href=videoUrl download='video.mp4'> 'download'

		