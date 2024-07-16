import { collection, doc, getDoc, getDocs, setDoc, addDoc, onSnapshot, query, where, updateDoc, serverTimestamp } from 'firebase/firestore'
import { firestoreDB } from '../firebase.imba'

export def toggleSubscription(user, userDoc, channelId)
	const userDocRef = doc(firestoreDB, "users/{user.uid}")
	const subscriberDocRef = doc(firestoreDB, "channels/{channelId}/subscribers/{user.uid}")
	if userDoc
		const userData=userDoc.data()
		const subsArray = userData.subscriptions
		if subsArray.includes(channelId)
			const index = subsArray.indexOf(channelId)
			subsArray.splice(index, 1)
			await setDoc(userDocRef, subscriptions:subsArray, {merge:true})
		else
			subsArray.push(channelId)
			await setDoc(userDocRef, subscriptions:subsArray, {merge:true})

		const q = query(collection(firestoreDB, "{userDocRef.path}/subscriptions"), where('channelId', '==', channelId))
		await getDocs(q).then do(querySnapshot)
			const doc = querySnapshot.docs[0]
			if doc
				let docData = doc.data()
				if docData.subscribed  # already subscribed -> remove subscription from doc
					let newData = {subscribed:false, unsubscribedAt:serverTimestamp()}
					await setDoc(doc.ref, newData, {merge:true})
					await setDoc(subscriberDocRef, newData, {merge:true})
					
				else				# doc exists but not subscribed -> add subscription to doc
					let newData = {subscribed:true, subscribedAt:serverTimestamp()}
					await setDoc(doc.ref, newData, {merge:true})
					await setDoc(subscriberDocRef, newData, {merge:true})
			else  # doc does not exist and is not subscribed
				const newData = {
					channelId:channelId
					subscribed:true
					subscribedAt:serverTimestamp()
				}
				await addDoc(collection(firestoreDB, "{userDocRef.path}/subscriptions"), newData)
		

	else
		console.log 'faça o login antes'