
# https://firebase.google.com/products/extensions/firebase-firestore-counter

import { firestoreDB } from '../firebase.imba'
import { writeBatch, doc, collection, onSnapshot, updateDoc, increment, query } from 'firebase/firestore'

export def createCounter(path, shardsNum) # ref is a doc
	# console.log 'hi'

	const docRef = doc(firestoreDB, path)
	const batch = writeBatch(firestoreDB)

	batch.update(docRef, {shardsNum, docRef})

	for i in [0...shardsNum]
		const shardRef = doc(firestoreDB, "{path}/shards/{i}")
		batch.set(shardRef, {count:0})

	await batch.commit()


export def incrementCounter(path, shardsNum)
	const shardId = Math.floor(Math.random()*shardsNum)
	const shardRef = doc(firestoreDB, "{path}/shards/{shardId}")
	await updateDoc(shardRef, {count: increment(1)})


export def decrementCounter(path, shardsNum)
	const shardId = Math.floor(Math.random()*shardsNum)
	const shardRef = doc(firestoreDB, "{path}/shards/{shardId}")
	await updateDoc(shardRef, {count:increment(-1)})


export def getCount(path)
	const shardsRef = collection(firestoreDB, "{path}/shards")
	let q = await query(shardsRef)
	return onSnapshot(q, do(querySnapshot)
		let totalCount = 0
		querySnapshot.forEach do(doc)
			console.log 'hi'
			totalCount += doc.data().count
	)
