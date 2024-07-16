import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, orderBy, serverTimestamp } from 'firebase/firestore'
import { auth, firestoreDB } from '../firebase.imba'

tag save-favorite-button

	prop user = auth.currentUser
	prop saved = false
	prop contentsData = {}
	

	css 
		button bgc:rgba(0,0,0,0) bd:none rd:md d:flex ai:center jc:center
		span fs:18px
		.saved c:blue4

	def saveContent
		const collectionRef = collection(firestoreDB, "users/{user.uid}/savedContent")
		if user
			saved = !saved
			const content = {
				userID : user.uid
				createdAt: serverTimestamp()
				type: contentsData.type
				content: contentsData.content
			}
			addDoc(collectionRef, content)

	<self>
		<button @click=saveContent>
			if saved
				<span.saved .material-icons> 'bookmark_added'
			else
				<span.empty .material-icons-outlined> 'bookmark_add'
