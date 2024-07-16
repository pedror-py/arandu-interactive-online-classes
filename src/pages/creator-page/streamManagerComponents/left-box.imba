import './answer-questions.imba'
import './quiz-results.imba'

import chat from '../../../assets/icons/chat-icon.svg'
import perguntas from '../../../assets/icons/perguntas-icon.svg'
import quiz from '../../../assets/icons/quiz-icon.svg'

tag left-box

	prop user
	prop streamId
	prop streamStates = null
	prop display = 'questions'
	prop streamData

	css self 
		h:70% 
		w:100% d:vflex 
		# jc:space-around 
		background: var(--ui-header, #1E1A20);
		justify-content: flex-start;
		align-items: center;
		# gap: 32.9375rem;
		flex-shrink: 0;
		.tabs
			display: flex;
			width: 100%;
			height: 2rem;
			justify-content: space-between;
			align-items: center;
			flex-shrink: 0;
			.tab
				display: flex;
				padding: 0.5rem;
				justify-content: center;
				align-items: center;
				gap: 0.3rem;
				flex: 1 0 0;
				cursor:pointer
				align-self: stretch;
				border-bottom: 1px solid rgba(255, 255, 255, 0.50);
				o:0.4
				&.selected
					border-bottom: 3px solid var(--principal-branco, #ffffff);
					background: var(--ui-container, #27232A);
					o:1
		svg
			s:15px
			fill:white
			o:1
			&.selected
			
		.text
			font-family: Poppins;
			font-size: 0.8rem;
		.contents h:calc(100% - 2rem) w:100%
		# 	button w:30%

	<self>
		<div.tabs>
			<div.tab .selected=(display=='chat') type='button' @click=(display='chat')>
				<svg src=chat>
				<div.text> 'Chat'
			<div.tab .selected=(display=='questions') type='button' @click=(display='questions')>
				<svg src=perguntas>
				<div.text> 'Perguntas'
			<div.tab .selected=(display=='quiz') type='button' @click=(display='quiz')> ''
				<svg src=quiz>
				<div.text> 'Quiz'
			# <button type='button' @click=(display='contribuições')> 'contribuições'

		<div.contents> if streamId
			if display === 'chat'
				<free-chat user=user streamId=streamId> 
				# if streamStates
				# 	if streamStates.chatOpen
				# 		<free-chat user=user streamId=streamId> 
				# 	else
				# 		<span> 'O chat está fechado'
				# 		<button @click=emit('toggleChat')> 'Abrir chat'
			if display === 'questions'
				<answer-questions streamId=streamId>
			if display === 'quiz'
				<quiz-results streamId=streamId streamData=streamData>