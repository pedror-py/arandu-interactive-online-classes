import { signInWithEmailAndPassword, createUserWithEmailAndPassword, onAuthStateChanged, signInAnonymously, GoogleAuthProvider, signInWithPopup} from 'firebase/auth'

import { auth } from '../firebase.imba'
let user = null

const googleProvider = new GoogleAuthProvider()

tag sign-in

	prop txtEmail\string
	prop txtPassword\string

	css .signInForm w:300px d:flex fld:column ai:flex-end
		button w:100px
		input ml:10px
	
	def newUserEmailPassword
		await createUserWithEmailAndPassword(auth, txtEmail, txtPassword)
			.then( do(userCredential)
				user = userCredential.user
				emit('userLoggedIn', user)
				console.log "Logged In {user.email}")
			.catch( do(error)
				const errorMessage = error.message
				console.error errorMessage)

	def loginWithGoogle
		signInWithPopup(auth, googleProvider)
			.then(do(res)
				const credential = GoogleAuthProvider.credentialFromResult(res)
				const token = credential.accessToken
				const user = res.user
				emit('userLoggedIn', user)
				console.log "Logged In {user.email}")
			.catch(do(error)
				const errorCode = error.code
				const errorMessage = error.message
				const email = error.customData.email
				const credential = GoogleAuthProvider.credentialFromError(error)
				error.log errorCode errorMessage)


	<self.signin>
		<div.signInBox>
			<h4> 'Coloca os dado ai'
			<form.signInForm @submit=emit('userLoggedIn', user)>
				<label [p:5px]> 'Email'
					<input.email  contentsData=txtEmail>
				<label [p:5px]> 'Password'
					<input.password contentsData=txtPassword>
				<button.bttNewUser type='submit' @click.prevent=newUserEmailPassword> 'Sign In'
				<button.bttSignIn type='button' @click.prevent=loginWithGoogle> 'Log In com conta do Google'


