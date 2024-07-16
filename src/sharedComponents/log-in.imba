import { signInWithEmailAndPassword, createUserWithEmailAndPassword, updateProfile , GoogleAuthProvider, signInWithPopup,EmailAuthProvider, FacebookAuthProvider } from 'firebase/auth'
import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, serverTimestamp } from 'firebase/firestore'
import { getApp } from 'firebase/app'
import { auth, firestoreDB } from '../firebase.imba'

import google from '../assets/icons/google-logo.svg'
import face from '../assets/icons/facebook-logo.svg'


let user = null

const googleProvider = new GoogleAuthProvider()
const facebookProvider = new FacebookAuthProvider()

tag log-in

	prop user
	prop userDoc
	prop username
	prop txtEmail\string
	prop txtPassword\string
	prop rePassword
	prop signingUp = false
	prop useEmail = false
	prop error
	prop authProvider

	def unmount
		useEmail=false
		signingUp = false
		error = ''
		txtEmail=''
		txtPassword=''
		rePassword=''

	def loginEmailPassword
		await signInWithEmailAndPassword(auth, txtEmail, txtPassword)
			.then( do(userCredential)
				user = userCredential.user
				console.log "Logged In {user.email}"
				)
			.catch( do(error)
				const errorCode = error.code
				const errorMessage = error.message
				console.error(errorCode, errorMessage))

	def signUpUserWithEmail
		if txtPassword === rePassword
			createUserWithEmailAndPassword(auth, txtEmail, txtPassword).then do(userCredential)
				user = userCredential.user
				updateUser()
		else error = 'As senhas não batem'

	def updateUser()
		userDoc = doc(firestoreDB, "users/{user.uid}")
		await getDoc(userDoc).then do(doc)
			if doc.exists
				return
			else
				const data = {photoUrl:"https://avatars.dicebear.com/api/identicon/{username}.svg"}
				if username
					data.displayName = username
				else
					username = user.displayName
				await updateProfile(user, data).then do
					createUserChannel()

	def createUserChannel
		# create user channel
		const channelsCollection = collection(firestoreDB, "channels")
		const channelData = {
			channelName:username
			mainChannel:true
			ownerId:user.uid
			description:''
			createdAt:serverTimestamp()
		}
		await addDoc(channelsCollection, channelData).then do(channelDoc)
			createUserDoc(channelDoc)


	def createUserDoc(channelDoc)
		# create user profile at firestore
		let channelId = channelDoc.id
		const docRef = doc(firestoreDB, "users/{user.uid}")
		const dark = checkPreferedColorScheme()
		const userData = {
			username
			uid:user.uid
			email:user.email
			authProvider
			channels: [channelId]
			subscriptions: []
			preferences:{
				dark
			}
			createdAt:serverTimestamp()
		}
		await setDoc(docRef, userData)

	def checkPreferedColorScheme	
		let dark
		if window.matchMedia('(prefers-color-scheme: dark)').matches
			dark = true
		elif window.matchMedia('(prefers-color-scheme: light)').matches
			dark = false
		else
			dark = null
		return dark
	
	def loginWithGoogle
		signInWithPopup(auth, googleProvider)
			.then(do(res)
				const credential = GoogleAuthProvider.credentialFromResult(res)
				const token = credential.accessToken
				user = res.user
				authProvider = 'google'
				console.log user
				updateUser()
				console.log "Logged In {user.displayName}")
			.catch(do(error)
				const errorCode = error.code
				const errorMessage = error.message
				# const email = error.customData.email
				# const credential = GoogleAuthProvider.credentialFromError(error)
				console.error(errorCode, errorMessage))

	def loginWithFacebook
		signInWithPopup(auth, facebookProvider)
			.then(do(res)
				const credential = FacebookAuthProvider.credentialFromResult(res)
				const token = credential.accessToken
				user = res.user
				authProvider = 'facebook'
				console.log user
				updateUser()
				console.log "Logged In {user.email}")
			.catch(do(error)
				const errorCode = error.code
				const errorMessage = error.message
				# const email = error.customData.email
				# const credential = GoogleAuthProvider.credentialFromError(error)
				console.error(errorCode, errorMessage))

	css self 
			pos:fixed
			w:100vw h:100vh
			bgc:black/50
		.container
			d:flex
			# ai:center
			# jc:center
			pos:absolute l:50% x:-50% t:50% y:-55%
			width: 80vw;
			height: 80vh;
			flex-shrink: 0;
			border-radius: 1rem;
			background: #27232A
			box-shadow: 0px 4px 8px 0px rgba(0, 0, 0, 0.10);
		.loginContainer
			w:50%
		.loginBox
			d:vflex
			ai: center;
			pt:2rem
			# jc:flex-start
			gap: 1rem;
		.loginForm
			display: flex;
			width: 15rem;
			flex-direction: column;
			align-items: flex-start;
			gap: 1rem;
			.title
				display: flex;
				flex-direction: column;
				align-items: flex-start;
				align-self: stretch;
				div
					color: var(--principal-laranja, #E58320);
					font-size: 1.5rem;
					# font-weight: 500;
					line-height: 120%;
			.inputs
				ff:Poppins
				display: flex;
				flex-direction: column;
				align-items: flex-start;
				gap: 1rem;
				align-self: stretch;
			.buttons
				ff:Poppins
				display: flex;
				flex-direction: column;
				align-items: flex-start;
				gap: 2rem;
				w:100%
				.providerButton
					w:3rem
					display: flex;
					padding: 0.5rem;
					justify-content: center;
					align-items: center;
					gap: 0.875rem;
					flex: 1 0 0;
					border-radius: 0.5rem;
					background:#ffffff;
			a
				text-decoration-line: underline
				cursor:pointer
				c:white
		.img
			w:50%
			rd:2rem 1rem 1rem 2rem
			bgc:var(--laranja-arandu)

	# transform: translate(calc(100vw - 200px), 7rem)

	def render
		<self>
			# <div.background>
			<div.container>
				<global @pointerdown.outside=emit('closePopUp')>
				<div.loginContainer>
					<div.loginBox>
						<logo color='#ffffff'>
						<form.loginForm @submit.prevent=loginEmailPassword>
							<div.title>
								<div> 'Login'
							<div.inputs [fs:0.75rem]>
								<input-arandu label='Email' type='email' name='email' required=true 
									bind:value=txtEmail 
									[w:15rem]
								>
								<input-arandu label='Senha' type='password' name='password' required=true 
									bind:value=txtPassword 
									[w:15rem]
								>
								<div [fs:0.7rem]> "Ainda não tem uma conta? "
									<a route-to="./cadastro"> 'Cadastrar-se'
							<div.buttons [fs:0.75rem]>
								<div [d:vflex]>
									<button-arandu text='Entrar' type='submit' @click=(useEmail=true) svg='' [w:15rem]>
									<a [as:center]> "Não consigo acessar minha conta"
								<div [d:flex w:100% jc:center ai:center g:3rem]>
									<button.providerButton type='button' @click=loginWithGoogle>
										<svg src=google>
									<button.providerButton type='button' @click=loginWithFacebook>
										<svg src=face>

				<div.img>
				# <logo color='#ffffff' vertical=true>


	# css self zi:999999999
	# 	.background pos:absolute w:100vw h:100vh bgc:black/50 l:50% x:-50% t:50% y:-50%
	# 	.container
	# 		pos:absolute  mt:5px of:hidden l:50% x:-50% t:50% y:-50% zi:9999999999
	# 		w:300px h:300px bgc:blue1 bd:1px solid black rd:15px p:10px
	# 	.logInBox d:vflex
	# 	.logInForm d:vflex

	# # transform: translate(calc(100vw - 200px), 7rem)

	# def render
	# 	<self>
	# 		<div.background>
	# 			<div.container>
	# 				<global @pointerdown.outside=emit('closePopUp')>
	# 				<h4 [m:0]> 'Faça o login'
	# 				<div.logInBox>
	# 					if !useEmail
	# 						<button.bttSignIn type='submit' @click=(useEmail=true)> 'Login com email e password'
	# 						<button.bttSignIn type="button" @click=loginWithGoogle> 'Login com Google'
	# 						<button.bttSignIn type="button" @click=loginWithFacebook> 'Login com Facebook'
	# 					if useEmail && !signingUp
	# 						<form.logInForm @submit.prevent=loginEmailPassword>
	# 							<label [p:5px]> 'Email'
	# 								<input.email required=true bind=txtEmail name='email'>
	# 							<label [p:5px] name='password'> 'Senha'
	# 								<input.password required=true type='password' bind=txtPassword>
	# 							<button.bttSignIn type='submit'> 'Login'
	# 						<button type='button' @click=(signingUp = true)> 'Criar nova conta'
	# 					if signingUp
	# 						<form.logInForm @submit.prevent=signUpUserWithEmail>
	# 							<label [p:5px]> 'Nome de usuário'
	# 								<input.username required=true  bind=username name='username'>
	# 							<label [p:5px]> 'Email'
	# 								<input.email required=true bind=txtEmail name='email'>
	# 							<label [p:5px] name='password'> 'Senha'
	# 								<input.password required=true type='password' bind=txtPassword>
	# 							<label [p:5px] name='password'> 'Repita a senha'
	# 								<input.password required=true type='password' bind=rePassword>
	# 							<button.bttSignIn type='submit'> 'Registrar'
	# 					<div [c:red]> error