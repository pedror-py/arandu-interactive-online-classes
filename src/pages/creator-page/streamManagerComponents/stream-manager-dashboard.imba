import optionsIcon from '../../../assets/icons/options-icon.svg'
import chat from '../../../assets/icons/chat-icon.svg'
import position from '../../../assets/icons/position-icon.svg'
import drawIcon from '../../../assets/icons/draw-icon.svg'
import window from '../../../assets/icons/interactable-window-icon.svg'
import micIcon from '../../../assets/icons/mic-icon.svg'
import camIcon from '../../../assets/icons/cam-icon.svg'

const optionsButtons = {
	position:{
		emit: 'repositionCamera'
		text:'Posição'
		icons: {
			on:position
		}
	}
	mic:{
		emit: 'toggleMic'
		text: 'Microfone'
		active: false
		icons:{
			on: micIcon
			# off:micOff
		}
	}
	webcam:{
		emit: 'toggleWebcam'
		text: 'Webcam'
		active: false
		icons:{
			on: camIcon
			# off:camOff
		}
	}
	onlyCamera:{
		emit: 'onlyCamera'
		text: 'onlyCamera'
		icons:{
			on: optionsIcon
		}
	}
}

const livestreamButtons = {
	draw:{
		emit: 'togglePaint'
		text:'Desenhar'
		active: false
		icons: {
			on: drawIcon
		}
	}
	chat:{
		emit: 'toggleChat'
		text: 'Chat'
		icons:{
			on:chat
		}
	}
	window:{
		emit: 'getWindowStream'
		text: 'Janela Interativa'
		active: false
		icons:{
			on: window
		}
	}
	livestreamOptions:{
		emit: 'toggleLivestreamOptions'
		text: 'Mais Opções'
		icons:{
			on: optionsIcon
		}
	}
}



tag stream-manager-dashboard

	prop chatOpen
	prop allowReactions
	prop streaming
	prop screenSharing
	prop windowSharing
	prop cameraSharing
	prop onlyCamera
	prop paintOpen

	prop camOpen = false
	prop micOpen = false

	def startStream
		emit('startStream')
		# emit('startStream', streaming)
		console.log streaming ? 'stream ended' : 'stream started'

	css self 
			w:100% h:25%
			flex-shrink: 0;
			border: 1px solid var(--ui-text-input, #413947);
			background: var(--ui-container, #27232A);
			box-shadow: 0px -4px 9px 0px rgba(0, 0, 0, 0.10);
			d:flex
		.container
			w:50% h:100%
			d:vflex
			box-sizing: border-box
			border: 1px solid var(--ui-text-input, #413947);
		.title
			h:15% w:100%
			fs:0.9rem
			bg:var(--ui-container)
			ff:Poppins
			# line-height: 200%
			o:0.8
			box-sizing: border-box
			pl:1.5rem
		.box 
			w:100% h:85%
			bg:var(--ui-header)
			d:flex
			ai:center
			jc:center
		.buttons
			h:80%
			w:90%
			border-radius: 0.5rem
			bg:var(--ui-container)
			d:flex
			ai:center
			jc:space-around

	def render
		
		optionsButtons.webcam.active = camOpen
		optionsButtons.mic.active = micOpen
		livestreamButtons.window.active = windowSharing
		livestreamButtons.draw.active = paintOpen

		<self>
			<div.container>
				<div.title> 'Minhas Opções'
				<div.box>
					<div.buttons>
						for own key, value of optionsButtons
							<DashboardButton type=key data=value active=value.active>
			<div.container>
				<div.title> 'Livestream'
				<div.box>
					<div.buttons>
						for own key, value of livestreamButtons
							<DashboardButton type=key data=value active=value.active>
				# for own key, value of buttons
				# 	<button 
				# 		@click.if(key=='openMedia')=emit('openMedia')
				# 		@click.if(key=='startStream')=startStream
				# 		@click.if(key=='editStreamData')=emit('editStreamData')
				# 		@click.if(key=='screenShare')=emit('screenShare', screenSharing)
				# 		@click.if(key=='createQuiz')=emit('newQuiz')
				# 		@click.if(key=='answer')=emit('answer')
				# 		@click.if(key=='openChat')=(do chatOpen = !chatOpen; emit('toggleChat'))
				# 		@click.if(key=='allowReactions')=(do allowReactions = !allowReactions; emit('toggleReactions'))
				# 		@click.if(key=='showContributions')=emit('showContributions')						
				# 		@click.if(key=='paint')=emit('togglePaint')						
				# 		@click.if(key=='windowShare')=emit('getWindowStream')						
				# 		@click.if(key=='onlyCamera')=emit('onlyCamera')					
				# 		# @click.if(key=='addMedia')=emit('addMedia')					
				# 	> 
				# 		<span .material-icons-outlined [fs:18px] 
				# 			[c:green4]=((key=='openChat' && chatOpen) or (key=='allowReactions' && allowReactions) or(key=='onlyCamera' && onlyCamera && cameraStream))
				# 			[c:red4]=((key=='startStream' && streaming) or (key=='screenShare' && screenSharing))
				# 		> value.icon
				# 		<span [fs:0.6rem]> 
				# 			if key === 'startStream'
				# 				streaming ? value.btt2 : value.btt
				# 			elif key === 'screenShare'
				# 				screenSharing ? value.btt2 : value.btt
				# 			else
				# 				value.btt
							


tag DashboardButton

	prop type = null
	prop data
	prop active
	prop redButtons = ['mic', 'webcam']
	prop whiteButtons = ['position','draw', 'optionsOptions', 'livestreamOptions']
	prop borderButtons = ['mic', 'webcam', 'chat', 'window']


	css self
			ff:Poppins
			fs:0.7rem
			d:vflex ai:center jc:space-around
			g:1rem
		.border 
			s:32px rd:50% 
			d:flex ai:center jc:center
			pos:relative
			&.green
				bd:2px solid green
			&.none bd:none 
			&.red bd:2px solid red
		.redLine 
			w:2px h:100% 
			pos:absolute rotate:45deg
			bg:red
		svg
			s:23px
			fill:#ffffff
			o:0.4
			&.active
				fill:#5EB137
				o:1  # D92424 red    #5EB137 green
			&.red
				fill:#D92424
			&.white
				fill:#ffffff
				o:1

	def render
		<self 
		@click=emit(data.emit)
		# @click=(active=!active)
		>
			<div .border .green=(active && borderButtons.includes(type)) 
			# .none=!redButtons.includes(type) 
			.red=(!active && redButtons.includes(type))>
				<div .redLine=(!active && redButtons.includes(type))>
				<svg
				.active=active 
				.red=(!active && redButtons.includes(type))
				.white=(active && whiteButtons.includes(type))
				src=data.icons.on>
			<div> data.text