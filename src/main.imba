



import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, serverTimestamp } from 'firebase/firestore'
import {auth, firestoreDB} from './firebase.imba'

# import * as dotenv from 'dotenv'

import "./global-components-imports.imba"

# import styles
import "./globalCSS/globalCSS.imba"
import "./globalCSS/globalVariablesCSS.imba"
import "./sharedComponents/styledComponents/styled-components.imba"

# import shared components
import "./sharedComponents/nav-bar.imba"
import "./sharedComponents/user-sidebar.imba"
import "./sharedComponents/alert-box.imba"
import "./sharedComponents/upload-test.imba"
import "./sharedComponents/initial-questionaire.imba"

# # import pages
import "./pages/homepage/homepage.imba"
import "./pages/stream-page/stream-page.imba"
import "./pages/creator-page/creator-page.imba"
import "./pages/login-page/login-page.imba"
import "./pages/saved-content-page/saved-content-page.imba"
import "./pages/channel-page/channel-page.imba"

# # tests imports
import "./tests/mouse-sim.imba"
import "./sharedComponents/yt-iframe.imba"
import "./tests/test-recorder.imba"
# import "./tests/code-editor-python.imba"
# import  "./APIs/streaming-uploads.imba"
# import  "./APIs/streaming-uploads-test.imba"
# import "./gcloud-test.imba"
# import {testAI} from  "./APIs/openAI-API.imba"

# let globalAppState = new MyAppState()
let globalAppState = {
	key1:'value1'
	key2:'value2'
}

# Extend 'element' with a new property for getting an app state value
extend tag element
	get appState
		return globalAppState

# # Now any tag can use the 'appState' property
# tag Foo
#   <self> appState.someValue


tag app

	@observable user = null
	prop userDoc
	prop currentRoute
	prop showSidebar = false
	prop pageMemo
	prop authListener
	prop userDataListener\Function
	prop popUp = ''
	prop currentPath
	prop creatorMode = false
	prop streamManager = false
	prop darkMode


	@autorun def refresh
		imba.commit()

	def awaken
		# console.log import.meta.env.VITE_GN_ENDPOINT
		authListener = auth.onAuthStateChanged do(usuario)
			if usuario
				popUp === 'login' ? popUp = '' : popUp
				user = usuario
				# userDataListener()
				userDataListener = onSnapshot(doc(firestoreDB, "users/{user.uid}"), do(doc)
					userDoc = doc
					darkMode  = userDoc.data().preferences.dark
					imba.commit()
				)
			else
				user = null
			imba.commit()
	
	def unmount
		authListener()
		userDataListener()

	def login(e)
		popUp = 'login'

	def signOut
		auth.signOut()
		userDoc = null
		$navbar.showUserMenu = false

	def toggleDarkMode()
		if userDoc
			const data = userDoc.data()
			const dark = data.preferences.dark || null
			if dark != null
				updateDoc(userDoc, {preferences:{dark: !dark}})

	css self 
		h:100vh bg:var(--uibg)

	def render
		currentPath = imba.router.path
		if currentPath.includes('home')
			imba.router.replace('/')

		creatorMode = currentPath.includes('creator') ? true : false
		streamManager = currentPath.includes('stream-manager') ? true : false

		<self .light=true
		@toggleSidebar=(showSidebar = !showSidebar) 
		@closePopUp=(popUp='') 
		@login=login
		@toggleDark=(darkMode = !darkMode)
		>

			<nav-bar$navbar user=user showSidebar=showSidebar  @signOut=signOut>
			<main [d:vflex]>
				<user-sidebar user=user userDoc=userDoc colapsed=!showSidebar creator=creatorMode streamManager=streamManager>
				<section>
			
			# PAGES
			<homepage route='/'>
			<stream-page user=user userDoc=userDoc route='/stream'>
			if imba.router.match('/channel')
				let channel = currentPath.split('/')[2]
				console.log channel
				<channel-page user=user userDoc=userDoc route="/channel/{channel}" channelId=channel>
			# <login-page route='/login' previousPage=pageMemo>
			if userDoc
				<creator-page user=user route="/{user.uid}/creator" user=user userDoc=userDoc showSidebar=showSidebar streamManager=streamManager>
				<saved-content-page route="/{user.uid}/saved">

			# POPUPS
			if popUp === 'login'
				<log-in user=user>
			# if popUp === 'questionaire'
			# 	<initial-questionaire>

			# TESTS
			# <duo-programming route='/editor'>
			# # <code-editor-python route='/editorpy'>
			# # <mouse-sim route='/mouse'>
			# <video-player route='/video'>
			# <upload-test route='/upload'>
			# <yt-iframe route='/iframe'>
			# <terminal route='/terminal'>
			# <test-recorder route='/recorder'>
			# # <test-streaming-uploads>
			# # <button @click=testAI()> 'openAI'
			# # <alert-box>
			# <mediasoup-streamer route='/sms'>
			# <mediasoup-viewer route='/vms'>
			# <stream-manager-ux>

			

imba.mount <app>, document.getElementById "app"
