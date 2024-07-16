import { collection, doc, updateDoc, setDoc, onSnapshot, getDoc, query, orderBy, where, serverTimestamp} from 'firebase/firestore'
import { getFunctions, httpsCallable } from "firebase/functions"

import { firestoreDB, storage } from '../../firebase.imba'


import '../../tests/clip-video.imba'
import '../../tests/move-video.imba'
# import {testAI} from "../../APIs/openAI-API.imba"
import { transcriptionApi } from '../../APIs/transcription-api.js'

const functions = getFunctions();
const chatComplete = httpsCallable(functions, 'chatcomplete');
const translation = httpsCallable(functions, 'translation');

tag homepage

	prop liveStreams = []

	css self
		bg:var(--apoio-vermelho)
	
	prop mediaRecorder
	def transcribe-test()

		const stream = await window.navigator.mediaDevices.getUserMedia({audio:true})
		console.log 'mic on'
		const audioTracks = stream.getAudioTracks()
		let initialTimestamp
		if audioTracks.length > 0
			const audioStream = new MediaStream(audioTracks)
			mediaRecorder = new MediaRecorder(audioStream)
			mediaRecorder.onstart = do()
				initialTimestamp = new Date()
			mediaRecorder.ondataavailable = do(event)
				const timestamp = new Date() - initialTimestamp
				const audioBlob = new Blob([event.data], { type: 'audio/wav' });
				console.log timestamp
				transcriptionApi(audioBlob, timestamp)
			mediaRecorder.start(3000)

	def stopRecord
		mediaRecorder.stop()

	<self @closeModal>
		<main$main>
			# <div> "Homepage"
			# <button @click=testAI> 'aqui'
			# <iframe src="https://zapp.run/edit/flutter" style="width: 80%; height: 80%; border: 0; overflow: hidden;">
			# <iframe src="https://playcode.io/javascript" style="width: 80%; height: 80%">
			# <iframe src="https://codesandbox.io/embed/vanilla-vanilla?fontsize=14&hidenavigation=1&theme=dark"
			# 	style="width:100%; height:500px; border:0; border-radius: 4px; overflow:hidden;"
			# 	title="Vanilla"
			# 	allow="accelerometer; ambient-light-sensor; camera; encrypted-media; geolocation; gyroscope; hid; microphone; midi; payment; usb; vr; xr-spatial-tracking"
			# 	sandbox="allow-forms allow-modals allow-popups allow-presentation allow-same-origin allow-scripts"
			# >
			# <move-video>
			# <clip-video>
			# <stackblitz-ide streamer=true @ideChange=(ideFiles = e.detail)>
			# <stackblitz-ide streamer=false projectData=ideFiles>
			# <iframe src="https://phet.colorado.edu/sims/html/ph-scale/latest/ph-scale_pt_BR.html" width="800" height="600" allowfullscreen>
			# <css-test>
			# <modal>
			# <edit-stream-data>
			# <interaction-bar>
			# <stream-manager-ux>
			# <button @click=test> 'test apiiiiiiiiiiiiiiii'
			# <div> appState.key1
			# <input bind=appState.key1>
			# <button @click=console.log(appState)>
			# <button @click=transcribe-test> 'Record and transcribe'
			# <button @click=stopRecord> 'Stop Rec'


tag modal-1
	css self
		pos:absolute l:50% x:-50%
		display: flex
		flex-direction: column
		padding: 0 80px
		border-radius: 1rem
		background-color: var(--ui-container, #27232a)

		@media(max-width: 991px)
			padding: 0 20px

		.content-container
			display: flex
			margin-top: 80px
			flex-direction: column

			@media(max-width: 991px)
				max-width: 100%
				margin-top: 40px

		.account-access
			color: var(--principal-branco, #fff)
			font: 400 1.5rem/150% Poppins, sans-serif

			@media(max-width: 991px)
				max-width: 100%

		.recovery-instruction
			color: var(--principal-branco, #fff)
			opacity: 0.8
			margin-top: 16px
			font: 400 1rem/150% Poppins, sans-serif

			@media(max-width: 991px)
				max-width: 100%

		.email-label
			color: var(--principal-branco, #fff)
			opacity: 0.8
			margin-top: 32px
			font: 500 0.88rem/150% Poppins, sans-serif

			@media(max-width: 991px)
				max-width: 100%

		.input-container
			border-radius: 0.3125rem
			background-color: var(--ui-text-input, #413947)
			display: flex
			margin-top: 8px
			flex-direction: column
			padding: 14px 16px

			@media(max-width: 991px)
				max-width: 100%

		.placeholder-text
			color: var(--principal-branco, #fff)
			opacity: 0.5
			font: 400 0.88rem/150% Poppins, sans-serif

		.continue-button
			color: var(--principal-branco, #fff)
			text-align: center
			justify-content: center
			align-items: center
			border-radius: 0.5rem
			background-color: var(--principal-laranja, #e58320)
			margin: 32px 0 80px
			padding: 12px 20px
			font: 500 1rem/150% Poppins, sans-serif

			@media(max-width: 991px)
				max-width: 100%
				margin-bottom: 40px

	def render
		<self>
			<div.div>
				<div.content-container>
					<div.account-access> "Não consegue acessar sua conta?"
					<div.recovery-instruction> "Informe seu email para recuperar sua senha"
					<div.email-label> "Email de cadastro"
					<div.input-container>
						<div.placeholder-text> "Escrever..."
				<div.continue-button> "Continuar"




