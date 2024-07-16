import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, orderBy, serverTimestamp } from 'firebase/firestore'
import { auth, firestoreDB } from '../../../../firebase.imba'
import axios from 'axios'
import { nanoid } from 'nanoid'

import play from '../../../../assets/icons/play-button-icon.svg'
import send from '../../../../assets/icons/send-icon.svg'

tag ai-chat

	prop streamId
	prop streamData
	prop chatRoom
	prop txt = ''
	prop messages = []
	prop user
	prop loading = false
	prop chatsDocRef
	prop chatId
	prop unsubscribe

	def awaken
		# chatRoom = collection(firestoreDB, "streams/{streamId}/ai-chat")
		# chatRoom = collection(firestoreDB, "users/{user.uid}/ai-chats/{streamId}/chats")

		chatsDocRef = doc(firestoreDB, "users/{user.uid}/ai-chats/{streamId}")
		const chatsDoc = await getDoc(chatsDocRef)
		let data = chatsDoc.data()
		console.log data
		if chatsDoc.exists()
			chatId = chatsDoc.data().lastChatId
			chatRoom = collection(firestoreDB, "users/{user.uid}/ai-chats/{streamId}/{chatId}")
			listenToMessages()
		else
			newChat()

		console.log streamId
		console.log chatRoom.path



	def newChat()
		chatId = nanoid()
		chatRoom = collection(firestoreDB, "users/{user.uid}/ai-chats/{streamId}/{chatId}")
		await setDoc(chatsDocRef, {lastChatId:chatId})
		listenToMessages()

	def listenToMessages
		messages = []
		if unsubscribe
			unsubscribe()
		const q = query(chatRoom, orderBy('createdAt', 'asc'))
		unsubscribe = onSnapshot(q, do(querySnapshot)
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
				type:'user'
				name: user.displayName || user.email
				text: txt
				createdAt: serverTimestamp()
			}
			addDoc(chatRoom, data)
			getAIMessage()
			txt = ''
	
	def newAIMEssage(text)
		const data = {
			type: 'ai'
			name: 'AI'
			text,
			createdAt: serverTimestamp()
		}
		addDoc(chatRoom, data)

	def getAIMessage
		let url = "https://southamerica-east1-free-educ-app.cloudfunctions.net/function-1"

		const data = {
			question:txt
		}
		loading = true
		$dummy.scrollIntoView({ behavior:'smooth' })
		try
			const response = await axios.post(url, data)
			# .then do(response)
			newAIMEssage(response.data)
		catch e
			console.log e
			loading = false
		finally
			loading = false


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
		textarea w:80% h:80%
		# ml:10px rd:lg h:20px w:85%


	<self>
		if !messages.length
			<div.messages> 'Converse com uma IA e com os conteúdos'
		else
			<button @click=newChat> 'new chat'
			<div$msgs.messages>
				for message, i of messages
					<ai-chat-message contentsData=message>
				<loading [as:center]> if loading
			<div$dummy>
		
		<form.send @submit.prevent=newMessage>
			# <div.buttons>
			# <input-arandu [fs:0.7rem w:75%] label='' placeholder='Envie uma mensagem' bind:value=txt>
			<textarea [resize:none] placeholder='Converse com a IA' bind=txt>
			# <input type='text' placeholder='Envie uma mensagem' bind=txt>
			<button.btt .sendBtt type='submit'>
				<svg src=send>


tag ai-chat-message

	prop contentsData

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
		.aiMessage bg:#E89846

	def render
		<self>
			if contentsData.type == 'user'
				<div.user> 'Você'
				<div.message> contentsData.text
				<div [h:5px]>
			if contentsData.type == 'ai'
				<span> '\u2728'
				<div.message .aiMessage> contentsData.text
				<div [h:5px]>


tag loading

	css	self
		.loader 
			margin: auto;
			border: 5px solid #EAF0F6;
			border-radius: 50%;
			border-top: 5px solid #FF7A59;
			# width: 50px;
			# height: 50px;
			s:20px
			animation: spinner 1s linear infinite;
			@keyframes spinner
				0% transform: rotate(0deg);
				100% transform: rotate(360deg);

	<self>
		<div.loader>


