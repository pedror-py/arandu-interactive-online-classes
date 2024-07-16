import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, serverTimestamp } from 'firebase/firestore'
import { firestoreDB } from '../../../firebase.imba'


tag edit-channel

	prop user
	prop channels
	prop selectedChannel # {channelId, channelName, channelRef}
	prop lastData

	css self
		main
			input, textarea w:50%

	def unmount
		cancelChanges()

	def cancelChanges
		selectedChannel = JSON.parse(JSON.stringify(lastData))

	def saveChannelData
		const channelRef = doc(firestoreDB, "channels/{selectedChannel.channelId}")
		await updateDoc(channelRef, selectedChannel)

	def newLink
		const newLink = {title:'', url:''}
		if selectedChannel.links
			selectedChannel.links.push(newLink)
		else
			selectedChannel.links = [newLink]

	def render
		console.log selectedChannel
		console.log channels
		<self>
			
			<form @submit.prevent=saveChannelData>
				<div.header [d:flex]>
					<div> "ID do canal: {selectedChannel.channelId}"
					<button type='button' route-to="/channel/{selectedChannel.channelId}"> 'Ver canal'
					<button @click=cancelChanges> 'Cancelar'
					<button type='submit'> 'Salvar'
				<main [d:vflex]>
					<label> 'Nome'
					<input type='text' bind=selectedChannel.channelName>
					<label> 'Descrição'
					<textarea [resize:none h:200px]>
					<label> 'URL do canal'
					<div>
					<div> 'Links'
					if selectedChannel.links
						for link, i of selectedChannel.links  # [{},{}]
							<div [d:flex]>
								<div>
									<label> 'Título do link'
									<input bind=link.title>
								<div>
									<label> 'URL'
									<input bind=link.url>
								<button type='button' @click=(selectedChannel.links.splice(i, 1))> 'Excluir'
						<button [w:100px] type='button' @click=newLink> 'Adicionar link'
					<div>

				