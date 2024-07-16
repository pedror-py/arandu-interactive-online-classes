import { collection, doc, onSnapshot, query, orderBy} from 'firebase/firestore'

import { auth, firestoreDB } from '../../../firebase.imba'

import upvote from '../../../assets/icons/upvote-icon.svg'
import answer from '../../../assets/icons/answer-icon.svg'

tag answer-questions

	prop streamId
	prop questionsRoom
	prop perguntas = []

	css h:100% w:100% 
		background:#2C153C
		.tabs h:10%
		.perguntas h:100% d:vflex g:5px

	def awaken
		questionsRoom = collection(firestoreDB, "streams/{streamId}/perguntas")
		const q = await query(questionsRoom, orderBy('createdAt', 'desc'))
		const snap = onSnapshot(q, do(querySnapshot)
			querySnapshot.docChanges().forEach do(change)
				let docId = change.doc.id
				let docRef = change.doc.ref
				if change.type === 'added'
					let data = change.doc.data()
					perguntas.push({...data, docId, docRef, respondido:false})
				if change.type === 'removed'
					let removeIndex
					perguntas.forEach do(pergunta, i)
						if pergunta.docId === change.doc.id
						removeIndex = i
					perguntas.splice(removeIndex, 1)
			imba.commit()
		)

	<self>
		if !perguntas.length
			<div> 'Sem perguntas ainda'
		else
			<div.perguntas>	
				for pergunta, i of perguntas
					<question contentsData=pergunta index=i
						@stopAnswer=(perguntas[i].respondido=true)
					>

tag question

	prop contentsData
	prop index
	prop respondendo = false
	prop firstRender = true
	prop timeElapsed = " "

	def mount
		const intervalId = setInterval(&, 20000) do
			if contentsData
				const createdAt = contentsData.createdAt.toDate()
				const currentDate = new Date()
				let timediff = currentDate - createdAt
				timeElapsed = Math.floor((timediff / 1000 / 60) % 60)
				imba.commit()

	def getCount(path)
		const shardsRef = collection(firestoreDB, "{path}/shards")
		let q = await query(shardsRef)
		onSnapshot(q, do(querySnapshot)
			let totalCount = 0
			querySnapshot.forEach do(doc)
				totalCount += doc.data().count
			contentsData.upCount = totalCount
			imba.commit()
		)

	def startStopAnswer
		respondendo = !respondendo
		respondendo ? emit('answering', contentsData) : emit('stopAnswer', {contentsData, index})

	css	self
			d:vflex m:0.5rem
		.username
			color: var(--principal-branco, #FFF);
			font-family: Poppins;
			font-size: 0.7rem;
			o:0.8
		.container	
			border-radius: 0.25rem;
			background: var(--apoio-laranja-leve, #FDF1E5);
			padding: 0.25rem 0.5rem;
		.content
			d:flex
		.pergunta
			color: var(--ui-container, #27232A);
			font-family: Poppins;
			font-size: 0.85rem;
		.up
			d:flex c:black
			svg c:black
		.timeElapsed
			align-self: stretch;
			color: var(--principal-branco, #FFF);
			text-align: right;
			font-family: Poppins;
			font-size: 0.5rem;
			opacity: 0.7;
		.startStopBtt
			bg:rgba(0, 0, 0, 0.4)
			s:25px
			rd:50%
			d:flex ai:center jc:center
		svg
			s:18px
			fill:#ffffff
		# .container d:vflex
		# 	.username fs:0.75rem d:flex ai:center
		# 	.upCount ml:auto fs:1rem fw:600
		# 	.commands d:flex
		# .pergunta maw:30ch fs:0.75rem
		# .startStopBtt d:flex jc:center ai:center rd:50% size:25px bd:1px solid black
		# .commands d:flex ai:center g:5px
		# .status w:80px h:20px fs:0.75rem
		# .upIcon transform:rotate(90deg)

	def render
		if firstRender
			getCount(contentsData.docRef.path)
			firstRender = false

		<self [bgc:green4]=contentsData.respondido>
			<span.username> contentsData.username
			<div.container>
				<div.content>
					<div.pergunta> contentsData.txtPergunta
					<div.up>
						<span.upCount> contentsData.upCount
						<svg fill='black' stroke='black' [c:black] src=upvote>
						# <span.upIcon [c:white fs:18px rd:50% bgc:blue3] .material-icons-round> 'arrow_back'
				<div.commands>
					<div.startStopBtt .btt @click=startStopAnswer>
						<svg src=answer>
						# <span .material-icons [fs:18px c:red4] [c:green4]=!respondendo> "{respondendo ? 'stop' : 'play_arrow'}"
					<div.status> "{respondendo ? 'respondendo...' : contentsData.respondido ? 'respondido' : ''}"
					# <button [ml:auto] @click=(skipped=true)> 'Pular'
			<div.timeElapsed> timeElapsed === 0 ? 'agora' : (timeElapsed!== ' ' ? "{timeElapsed}m" :  timeElapsed)
