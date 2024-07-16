import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, orderBy, serverTimestamp } from 'firebase/firestore'
import { auth, firestoreDB } from '../../../firebase.imba'

import play from '../../../assets/icons/play-button-icon.svg'
import send from '../../../assets/icons/send-icon.svg'

tag free-chat

	prop streamId
	prop streamData
	prop chatRoom
	prop txt = ''
	prop messages = []
	prop user


	def awaken
		chatRoom = collection(firestoreDB, "streams/{streamId}/chat")
		console.log streamId
		console.log chatRoom.path

		const q = query(chatRoom, orderBy('createdAt', 'asc'))
		const snap = onSnapshot(q, do(querySnapshot)
			querySnapshot.docChanges().forEach do(change)
				if change.type === 'added'
					let data = change.doc.data()
					messages.push(data)
					imba.commit()
					$dummy.scrollIntoView({ behavior:'smooth' })
		)

	def newMessage
		if txt
			const data = {
				user: user.displayName || user.email
				text: txt
				createdAt: serverTimestamp()
			}
			addDoc(chatRoom, data)
			txt = ''

	css self 
			d:vflex
			h:100% w:100% 
		.messages h:100% of:auto d:vflex p:8px
		.send 
			display: flex;
			width: 100%
			height: 3rem;
			# padding: 0.5rem 1rem 1rem 1rem;
			# flex-direction: column;
			align-items: center;
			jc:space-evenly
			gap: 0.5rem;
			flex-shrink: 0;
			background: var(--ui-container, #27232A);
		input 
			flg:1 p:5px mr:5px
		.sendBtt
			s:35px
			d:flex ai:center jc:center
			bd:1px solid var(--principal-laranja)
			rd:0.4rem
			bg:none
			@hover bg:rgba(255, 255, 255, 0.1)
			svg
				fill:var(--principal-laranja)
			
		# ml:10px rd:lg h:20px w:85%


	<self>
		if !messages.length
			<div.messages> 'Sem mensagens por enquanto...'
		else
			<div$msgs.messages>
				for message, i of messages
					let omitUser = false
					if messages[i - 1]
						if message.user === messages[i - 1].user
							omitUser = true
					<chat-message contentsData=message omitUser=omitUser>
				<div$dummy>

		
		<form.send @submit.prevent=newMessage>
			# <div.buttons>
			<input-arandu [fs:0.7rem w:75%] label='' placeholder='Envie uma mensagem' bind:value=txt>
			# <input type='text' placeholder='Envie uma mensagem' bind=txt>
			<button.btt .sendBtt type='submit'>
				<svg src=send>


tag chat-message

	prop omitUser=false
	prop contentsData
	prop timeElapsed = " "

	def awaken
		const intervalId = setInterval(&, 5000) do
			if contentsData
				const createdAt = contentsData.createdAt.toDate()
				const currentDate = new Date()
				let timediff = currentDate - createdAt
				timeElapsed = Math.floor((timediff / 1000 / 60) % 60)
				imba.commit()

	css self 
			display: flex;
			flex-direction: column;
			align-items: flex-start;
			gap: 0.25rem;
			align-self: stretch;			
		.user
			color: var(--principal-branco, #FFF);
			font-family: Poppins;
			font-size: 0.75rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;
			opacity: 0.8;	
		.message
			display: flex;
			padding: 0.25rem 0.5rem;
			align-items: flex-start;
			gap: 0.5rem;
			border-radius: 0.25rem;
			background: rgba(255, 255, 255, 0.95);
			color: var(--ui-container, #27232A);
			font-family: Poppins;
			font-size: 0.875rem;
			font-style: normal;
		.timeElapsed
			align-self: stretch;
			color: var(--principal-branco, #FFF);
			text-align: right;
			font-family: Poppins;
			font-size: 0.5rem;
			opacity: 0.7;

	def render
		<self>
			if !omitUser
				<div.user> contentsData.user
			<div.message> contentsData.text
			
			<div.timeElapsed> timeElapsed === 0 ? 'agora' : (timeElapsed!== ' ' ? "{timeElapsed}m" :  timeElapsed)