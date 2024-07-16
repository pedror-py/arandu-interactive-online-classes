import { collection, doc, getDoc, setDoc, addDoc, onSnapshot, query, updateDoc, serverTimestamp } from 'firebase/firestore'
import {firestoreDB} from '../../firebase.imba'

import './channelPageComponents/channel-videos.imba'

import {toggleSubscription} from '../../utils/toggleSubscription.imba'

tag channel-page

	prop user
	@observable userDoc
	prop userData
	prop subscribed = false
	prop owner = false

	prop channelId
	prop channelDocRef
	prop channelDoc
	prop channelData

	@autorun def processUserData
		if userDoc
			userData = userDoc.data()
			if userData.subscriptions
				userData.subscriptions.includes(channelId) ? (subscribed = true) : (subscribed = false)
			if userData.channels
				userData.channels.includes(channelId) ? (owner = true) : (owner = false)
			imba.commit()

	def awaken
		channelDocRef = doc(firestoreDB, "channels/{channelId}")
		channelDataListener = onSnapshot(channelDocRef, do(doc)
			channelDoc = doc
			channelData = doc.data()
			imba.commit()
		)
	
	def unmount
		channelDataListener()

	css self w:100% of:auto
		main d:vflex w:100% h:100%
			.banner bgc:cool4 h:10rem
			.channelHeader d:flex h:5rem ai:center
				.subscribeBtt ml:auto
			.tabs d:flex w:100% bgc:cool5
				.tab w:6rem 

	def render		
		if channelData		
			<self>
				<main>
					<div.banner> 'banner'
					<div.channelHeader>
						<div>
							<img .avatar [w:40px] alt='avatar' src="https://avatars.dicebear.com/api/identicon/{channelId}.svg">
						<div.channelName> channelData.channelName
						if owner
						<button @click=(route-to="/{user.uid}/creator/editing")> 'Editar canal'
						<button.subscribeBtt 
						@click=toggleSubscription(user, userDoc, channelId)
						> subscribed ? 'Unsubscribe' : 'Subscribe'
					<div.tabs>
						<div.tab route-to=""> 'INÍCIO'
						<div.tab route-to="./videos"> 'VIDEOS'
						<div.tab route-to="./cortes"> 'CORTES'
						<div.tab route-to="./playlists"> 'PLAYLISTS'
						<div.tab route-to="./portifolio"> 'PORTIFÓLIO'
					<div.content>
						<section.inicio route="">
							<div.description> 'descrição'
							<div> 'programação'
							<div .destaques> 'destaques'
						<section route="videos"> 'videos'
							<channel-videos 
								channelData=channelData
								user=user
							>
						<section route="cortes"> 'cortes'
						<section route="portifolio"> 'Portifólio'