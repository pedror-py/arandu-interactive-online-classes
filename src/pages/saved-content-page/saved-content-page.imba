import { orderBy, limit, collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, serverTimestamp } from 'firebase/firestore'

import { auth, firestoreDB } from '../../firebase.imba' 


tag saved-content-page

	prop user = auth.currentUser
	prop savesRef
	prop recentSaves = []

	def awaken
		savesRef = collection(firestoreDB, "users/{user.uid}/savedContent")
		let q = query(savesRef, orderBy('createdAt'), limit(10))
		# console.log q

		onSnapshot(q, do(querySnapshot)
			querySnapshot.forEach do(doc)
				recentSaves.push(doc.data())
			imba.commit()
		)


	<self>
		<div.mainContainer>
			<div.recent> "Conteúdo salvo recentemente"
				if recentSaves
					for content of recentSaves
						<div.contentBox>
							<div> content.type
							<div> content.content

			console.log recentSaves