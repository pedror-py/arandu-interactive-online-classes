import { signInWithEmailAndPassword, createUserWithEmailAndPassword, onAuthStateChanged, signInAnonymously, GoogleAuthProvider, signInWithPopup, EmailAuthProvider, FacebookAuthProvider} from 'firebase/auth'

import { auth } from '../../firebase.imba'

import '../../sharedComponents/log-in.imba'

const signInOptions =  [
		provider:EmailAuthProvider.PROVIDER_ID
		{
			provider:GoogleAuthProvider.PROVIDER_ID
			customParameters: {
				prompt: 'select_account'
			}
		}
		{		
			provider:FacebookAuthProvider.PROVIDER_ID
			scopes:[
				'public_profile'
				'email'
				'user_likes'
				'user_friends'
			]
		}
	]
const callbacks = {
	signInSuccessWithAuthResult : do(authResult, redirectUrl)
		return true
}

tag login-page

	# prop autorender = 60fps
	prop previousPage
	prop ui
	prop uiConfig

	css w:300px pos:absolute l:calc(50vw - 150px) t:calc(50vh - 150px) bd:1px solid black rd:lg
		.text pl:55px

	# global css #firebaseui-auth-container 
	# 	.firebaseui-idp-list list-style:none d:vflex g:0.2rem p:0.2rem
	# 	.firebaseui-idp-button w:100% h:50px cursor:pointer d:flex ai:center g:20px fs:1.2rem bd:1px solid black
	# 	.firebaseui-idp-icon-wrapper h:100% d:vflex jc:center
	# 		img h:70%
	# 	.firebaseui-idp-text-long d:none
	# 	.firebaseui-title fs:1.2rem mx:0.2rem ta:center

	# def mount
	# 	const signInFlow = 'popup'
	# 	var signInSuccessUrl
	# 	if previousPage
	# 		signInSuccessUrl = previousPage
	# 	else signInSuccessUrl = 'http://localhost:3000/homepage'
	# 	uiConfig = {
	# 		signInOptions
	# 		callbacks
	# 		signInSuccessUrl 
	# 		signInFlow
	# 	}

	# def rendered
	# 	if !ui
	# 		ui = new firebaseUI.auth.AuthUI(auth)
	# 		ui.start('#firebaseui-auth-container', uiConfig)
	# 	var emailSignInTitle  = document.getElementsByClassName('firebaseui-title')
	# 	if emailSignInTitle.length > 0
	# 		emailSignInTitle[0].innerHTML = 'Login com email'

	def render

		<self>
			<span.text> 'Faça o login ou registre-se'
			<log-in>
			# <div #firebaseui-auth-container>
