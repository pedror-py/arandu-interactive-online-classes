import { orderBy, limit, collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, serverTimestamp } from 'firebase/firestore'
import { nanoid } from 'nanoid'

import { auth, firestoreDB } from '../../../firebase.imba'

import "./audio-recorder.imba"

tag notes-taker

	prop recording = false
	prop notes = []
	prop user = auth.currentUser
	prop notesRef
	prop streamData

	css  h:100% w:100% d:vflex
		.addButtons h:10% d:flex jc:space-evenly ai:center
			button h:60%
		.notes w:100% h:90% d:flex flw:wrap jc:space-evenly of:auto pt:5px 
		.recorder d:none h:300px w:250px bgc:blue4 rd:30px pos:fixed shadow:xl bd:1px solid black t:35%

	def awaken
		notesRef = collection(firestoreDB, "users/{user.uid}/notes")

	def newNote(type)
		if type === 'text'
			recording = false
			const data = {
				type
				id:nanoid()
				txt:''
			}
			notes.push(data)
		if type === 'audio'
			recording = true
	
	def noteEdit(e)
		let {index, txt} = e.detail
		notes[index].txt = txt

	def deleteNote(e)
		const i = e.detail
		notes.splice(i, 1)
	
	def addAudio(e)
		const blob = e.detail
		const data = {
			type:'audio'
			id:nanoid()
			blob
		}
		notes.push(data)

	<self 
		@noteEdit=noteEdit
		@deleteNote=deleteNote
		@newAudio=addAudio
	>
		<div.addButtons>
			<button @click=newNote('text')> 'Nova nota escrita'
			<button @click=newNote('audio')> 'Nova audionota'
		<div.notes>
			for note, i of notes
				<text-notes contentsData=note index=i> if note.type === 'text'
				<audio-notes contentsData=note index=i> if note.type === 'audio'
		
			<div.recorder [d:block]=recording>
				<audio-recorder @closeRecorder=(recording = false) recorder=null>

				
tag text-notes

	prop contentsData
	prop index
	prop txt

	css self 
			size:150px pos:relative h:100px
			@hover .deleteBtt d:block
		textarea w:100% h:100% bgc:amber2 rd:xl resize:none of:auto fs:1rem px:3px
		.deleteBtt pos:absolute t:0 r:0 rd:50% bd:none mt:2px size:20px d:none
			bgc:red3/85 @hover:red4

	<self>
		<textarea contentsData=txt @change=emit('noteEdit', {index, txt}) placeholder='Escreva uma nota...'>
		<button.deleteBtt 
			@click=(do
				emit('deleteNote', contentsData.index)
				txt='')
		> 'x'

tag audio-notes

	prop contentsData
	prop index

	css self 
			size:150px h:100px pos:relative bgc:sky2 rd:xl
			d:vflex jc:flex-start g:20% ai:center
			@hover .deleteBtt d:block
		audio w:140px 
		audio::-webkit-media-controls-time-remaining-display d:none
		audio::-webkit-media-controls-current-time-display d:none
		audio::-webkit-media-controls-mute-button d:none
		audio::-webkit-media-controls-volume-slider d:none
		.deleteBtt pos:absolute t:0 r:0 rd:50% bd:none mt:2px size:20px d:none
			bgc:red3/85 @hover:red4

	def render
		# if !data.blob
		# 	let blob = data.blob
		# 	$audio.src = "{URL.createObjectURL(blob)}"
		<self>
			<span> 'Audionota'
			<audio$audio src="{URL.createObjectURL(contentsData.blob)}" controls>
			<button.deleteBtt @click=emit('deleteNote', contentsData.index)> 'x'