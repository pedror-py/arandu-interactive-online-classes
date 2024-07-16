import { addDoc, collection, doc, getDoc, setDoc, updateDoc, deleteDoc, onSnapshot, query, where, orderBy, serverTimestamp } from 'firebase/firestore'

import { auth, firestoreDB } from '../../firebase.imba'

import './creatorPageComponents/creator-sidebar-menu.imba'
import './creatorPageComponents/planned-streams.imba'
import './streamPlannerComponents/stream-planner.imba'
import './streamManagerComponents/stream-manager.imba'
import './editChannelComponents/edit-channel.imba'
import './creatorContentsComponents/creator-contents.imba'

tag creator-page
	
	prop user
	prop userDoc
	prop showSidebar
	prop plannedStreams = [] # array of firestore doc with stream data
	prop streamsRef  # reference to collection of user streams (no stream data, only references)
	prop channels = []
	prop selectedChannel
	prop editingStream = null
	prop streamManager

	prop inPlanner
	prop streamDoc = null
	prop streamData = null


	def mount
		console.log 'creator mount'
		# const userStreams = collection(firestoreDB, "users/{user.uid}/streams")
		# suspend()
		listenToPlannedStreams()
		listenToUserChannels()
		const currentPath = imba.router.path
		if currentPath.includes('planned') & !currentPath.includes('new')
			const id = currentPath.split('planned/')[1]
			for item, i in plannedStreams
				if item.id == id
					streamSelected({detail:i})
		if currentPath.includes('stream-manager')
			const id = currentPath.split('/')[-1]
			console.log id
			for item, i in plannedStreams
				if item.id == id
					await streamSelected({detail:i})
		# unsuspend()

	# def mount
	# 	editingStream = null
	# 	streamDoc = null
	# 	streamData = null

	def listenToUserChannels
		const channelsIds = userDoc.data().channels
		for channelId, i of channelsIds
			channelRef = doc(firestoreDB, "channels/{channelId}")
			onSnapshot(channelRef, do(snapshot)
				const data = snapshot.data()
				data.channelId = snapshot.id
				channels[i] = data
				if !selectedChannel
					for channel of channels
						if channel.mainChannel
							selectedChannel = JSON.parse(JSON.stringify(channel))
							# selectedChannel = channel
				imba.commit()
				)

	def listenToPlannedStreams
		streamsRef = collection(firestoreDB, "users/{user.uid}/streams")
		const q = query(streamsRef, where('streamed', '==', false))
		onSnapshot(q, do(querySnapshot)
			querySnapshot.docChanges().forEach do(change)
				let data = change.doc.data()
				# get the stream doc in root/streams collection
				await getDoc(doc(firestoreDB, data.streamDocPath)).then do(streamDoc)
					if change.type === 'added'
						plannedStreams.push(streamDoc)
						# console.log 'added'
						# onSnapshot(streamDoc.ref, do(docSnap)
						# 	const newData = docSnap.data()
						# 	const newDoc = await getDoc(doc(firestoreDB, data.streamDocPath))
						# 	for stream, i of plannedStreams
						# 		if stream.id === streamDoc.id
						# 			plannedStreams[i] = newDoc
						# 	imba.commit()
						# 	console.log 'modified'
						# )
					if change.type === 'modified'
						console.log 'modified2'
						for stream, i of plannedStreams
							if stream.id === data.streamId
								plannedStreams[i] = streamDoc
					if change.type === 'removed'
						console.log 'deleted'
						for stream, i of plannedStreams
							if stream.id === data.streamId
								console.log stream.id, data.streamId
								plannedStreams.splice(i, 1)
					imba.commit()
				imba.commit()
		)
		console.log 'listened to streams'

	def newStream(e)
		console.log 'newStream()'
		if e.detail
			streamData = e.detail
		else
			streamData = {
				streamType: null
				streamed:false
				title:''
				tags:[]
				category:''
				dateTime: null
				contentsData: []
				userId:user.uid
				createdAt: serverTimestamp()
			}

		# add doc to streams collection at root (contains streamData)
		const docRef = await addDoc(collection(firestoreDB, "streams"), streamData)

		# add doc to streams collection inside user doc with reference
		const streamUserRef = {
			userId: user.uid
			streamId: docRef.id
			streamDocPath: docRef.path
			streamed:streamData.streamed
			dateTime:streamData.dateTime
			lastEdited:serverTimestamp()
		}
		const path = streamsRef.path + "/{docRef.id}"
		setDoc(doc(firestoreDB, path), streamUserRef)
		streamDoc = await getDoc(docRef)
		streamData = streamDoc.data()
		
		if !e.detail
			window.location.href = "http://{window.location.href.split('/')[2]}/{user.uid}/creator/stream-manager/{streamDoc.id}"

	def saveEditedStream(e)
		const { ref, data } = e.detail
		await updateDoc(ref, data)
		await updateDoc(doc(firestoreDB, "users/{user.uid}/streams/{streamDoc.id}"), { lastEdited:serverTimestamp() })
		
		streamDoc = null
		streamData = null
		editingStream = null
		console.log 'saveEditedStream()'
		# route-to = "/{user.uid}/creator/selection/plan"

	def streamSelected(e)
		const index = e.detail
		console.log index
		streamDoc = plannedStreams[index]
		streamData = streamDoc.data()
		console.log "streamDoc.id:", streamDoc.id
	
	def editStream(e)
		# e.detail --> index
		console.log 'editStream()'
		editingStream = e.detail
		console.log editingStream
		streamDoc = plannedStreams[editingStream]
		streamData = streamDoc.data()
		imba.commit()

	def deleteStream(e)
		const docRef = plannedStreams[e.detail].ref
		const id = plannedStreams[e.detail].id
		if window.confirm("Excluir os dados dessa transmissão permanentemente?")
			await deleteDoc(docRef)
			await deleteDoc(doc(firestoreDB, "users/{user.uid}/streams/{id}"))
			# imba.commit()
			

	css self 
			h:calc(100% - 50px) w:calc(100% - 62px) l:62px pos:relative
			d:flex ai:flex-start
			&.streamManager w:100% l:0
		main h:100% w:100%  d:flex 

	def render
		if selectedChannel
			<self
				.streamManager=streamManager
				# [w:100% l:0]=streamManager
				@newStream=newStream
			>
				# if !imba.router.path.includes('stream-manager')
				# 	<creator-sidebar-menu 
				# 		show=showSidebar 
				# 		channels=channels 
				# 		selectedChannel=selectedChannel
				# 		@inPlanner=(do(e) inPlanner = e.detail)
				# 	>
				<main>
					<planned-streams 
						user=user
						route="/{user.uid}/creator/selection"
						plannedStreams=plannedStreams
						inPlanner=inPlanner
						showSidebar=showSidebar
						@streamSelected=streamSelected
						@editStream=editStream
						@deleteStream=deleteStream
					>
					<stream-planner route="/{user.uid}/creator/planned" 
						user=user
						plannedStreams=plannedStreams
						streamsRef=streamsRef
						streamDoc=streamDoc
						streamData=streamData
						editingStream=editingStream
						@saveEditedStream=saveEditedStream
					>
					<stream-manager route="/{user.uid}/creator/stream-manager"
						user=user
						streamDoc=streamDoc
						streamData=streamData
						streamsRef=streamsRef
					>
					<edit-channel  route="/{user.uid}/creator/editing"
						user=user 
						selectedChannel=selectedChannel
						channels=channels
						lastData=(channels.filter(do(channel) channel.channelId === selectedChannel.channelId)[0])
					>
					<creator-contents route="/{user.uid}/creator/contents"
						user=user
						userDoc=userDoc
						streamsRef=streamsRef
						plannedStreams=plannedStreams
						# streamsRef=streamsRef
					>


					<stream-manager-ux route="/{user.uid}/creator/stream-manager-ux">

