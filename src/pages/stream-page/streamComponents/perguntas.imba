import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, orderBy, updateDoc, serverTimestamp, increment, deleteDoc } from 'firebase/firestore'

import { auth, firestoreDB } from '../../../firebase.imba'
import { createCounter, incrementCounter, decrementCounter } from '../../../utils/counter.imba'

import './audio-recorder.imba'

tag perguntas

	prop user
	prop streamDoc
	prop perguntasCol
	prop streamData
	prop perguntas = []
	prop snap
	prop shardsNum = 5


	def awaken
		console.log streamData
		perguntasCol = collection(firestoreDB, "streams/{streamData.streamId}/perguntas")
		q = await query(perguntasCol, orderBy('createdAt', 'desc'))
		snap = onSnapshot(q, do(querySnapshot)
			querySnapshot.docChanges().forEach do(change)
				let docId = change.doc.id
				let docRef = change.doc.ref
				let data = change.doc.data()
				if change.type === 'added'
					const userUpVoted = doc(firestoreDB, "{docRef.path}/upUsers/{user.uid}")
					await getDoc(userUpVoted).then do(res)
						let upVoted = res.exists()
						perguntas.push({...data, docId, docRef, upVoted})
				if change.type === 'removed'
					perguntas.forEach do(pergunta, removeIndex)
						if pergunta.docId === docId
							perguntas.splice(removeIndex, 1)
				imba.commit()
			imba.commit()
		)
	
	def updateCount(e)
		const {docId, totalCount} = e.detail
		for pergunta of perguntas
			if pergunta.docId == docId
				pergunta.upCount = totalCount
				imba.commit()
				console.log pergunta.upCount
		setTimeout(&, 2000) do()
			# perguntas.sort(do(a, b) b.upCount - a.upCount)
			imba.commit()
			# sortQuestions()

	def sortQuestions
		const newArray = []
		for x of perguntas
			newArray.push(x)

		const len = perguntas.length
		let i = 0
		while i < (len - 1)

			let j = 0
			while j < (len - i - 1)
				if newArray[j].upCount < newArray[j + 1].upCount
					[newArray[j], newArray[j + 1]] = [newArray[j + 1], newArray[j]]
				j += 1
				
			i += 1
		perguntas = {...newArray}
		console.log perguntas[i].upCount
		imba.commit()

		
	def up(e)
		const {docId, docRef} = e.detail
		const userUpVoted = doc(firestoreDB, "{docRef.path}/upUsers/{user.uid}")

		for pergunta of perguntas
			if pergunta.docId == docId
				console.log pergunta.upVoted
				pergunta.upVoted = !pergunta.upVoted

				if pergunta.upVoted
					await setDoc(userUpVoted, {upVoted:true}).then do
						await incrementCounter(docRef.path, shardsNum).then do
				else
					await deleteDoc(userUpVoted).then do
						await decrementCounter(docRef.path, shardsNum).then do

		imba.commit()

	def enviarPergunta e	
		if e.detail
			const pergunta = {
				user: user.uid
				username: user.email
				txtPergunta: e.detail
				# upCount: 0
				createdAt: serverTimestamp()
			}
			let docRef = await addDoc(perguntasCol, pergunta)
			await createCounter(docRef.path, shardsNum)

	css h:100% w:100% d:vflex
		.perguntas h:calc(100% - 3rem) of:auto d:vflex g:5px ai:center
		.ask h:3rem
		.send 
			display: flex;
			width: 100%
			height: 4rem;
			# padding: 0.5rem 1rem 1rem 1rem;
			# flex-direction: column;
			align-items: center;
			jc:space-evenly
			gap: 0.5rem;
			flex-shrink: 0;
			background: var(--ui-container, #27232A);
		textarea w:80% h:80%
		.postPergunta 
			w:50px h:40px bg:var(--principal-laranja) bd:none
			font-family:Poppins

	<self>
		<div.perguntas>
			for pergunta, i of perguntas
				<pergunta-item 
					user=user 
					contentsData=pergunta 
					upCount=pergunta.upCount
					upVoted=pergunta.upVoted
					index=i
					@upCount=updateCount
					@upVoted=up
				>

		<form.send @submit.prevent=enviarPergunta>
			<textarea [resize:none] placeholder='insira sua pergunta aqui' bind=txtPergunta>
			
			<button .postPergunta type='submit'> 'Enviar'
			# <button .postPergunta type='submit'> 'Audio'
		# <div.ask>
		# 	<ask-pergunta user=user @enviarPergunta=enviarPergunta>


tag pergunta-item

	prop user
	prop contentsData
	prop upVoted
	prop shardsNum
	prop unsusbcribe
	prop firstRender = true
	prop upCount
	prop index

	def getCount()
		const shardsRef = collection(firestoreDB, "{contentsData.docRef.path}/shards")
		let q = await query(shardsRef)
		onSnapshot(q, do(querySnapshot)
			console.log 'countiing'
			let totalCount = 0
			querySnapshot.forEach do(doc)
				totalCount += doc.data().count
			# upCount = totalCount
			emit('upCount', {docId:contentsData.docId, totalCount})
			imba.commit()
		)


	css	self bd:1px solid black rd:6px w:98% b:3px solid black bgc:var(--apoio-laranja-leve) c:var(--ui-container)
		.container d:vflex p:0.2rem pt:0 
		.username as:flex-start fs:0.6rem fw:600
		.upVote as:flex-end d:flex ai:center mt:0.3em
		.pergunta m:0 fs:1rem
		.upBtt bgc:rgba(0,0,0,0) bd:none
		.upIcon transform:rotate(90deg)

	def render
		if firstRender
			await getCount()
			firstRender = false
		<self>
			<div.container>
				<span.username> contentsData.username
				<p.pergunta> contentsData.txtPergunta
				<div.upVote>
					<span> contentsData.upCount
					<button.upBtt @click=emit('upVoted', {docId:contentsData.docId, docRef:contentsData.docRef})>
						<span.upIcon .material-icons [c:green3]=contentsData.upVoted> 'arrow_circle_left'

# tag ask-pergunta

# 	prop user
# 	prop username
# 	prop txtPergunta = ''

# 	css bgc:cool2 h:100%
# 		form d:flex h:90%
# 		textarea w:80%

# 	def enviarPergunta
# 		emit("enviarPergunta", txtPergunta)
# 		txtPergunta = ''

# 	<self>
# 		<form @submit.prevent=enviarPergunta>
# 			<textarea [resize:none] placeholder='insira sua pergunta aqui' bind=txtPergunta>
# 			<button .postPergunta type='submit'> 'Enviar'
# 			# <button .postPergunta type='submit'> 'Audio'


