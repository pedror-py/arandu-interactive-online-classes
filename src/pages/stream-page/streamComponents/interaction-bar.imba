import split from '../../../assets/icons/split-screen.svg'
import chat from '../../../assets/icons/chat-icon.svg'
import perguntas from '../../../assets/icons/perguntas-icon.svg'
import notes from '../../../assets/icons/notes-icon.svg'
import ai from '../../../assets/icons/ai-icon.svg'
import options from '../../../assets/icons/options-icon.svg'


const buttons = {
	split: {
		icon: split
		emit: 'toogleSplit'
		text: 'Interagir com conteúdo'
	}
	chat: {
		icon: chat
		emit: 'toggleChat'
		text: 'Chat'
	}
	perguntas: {
		icon: perguntas
		emit: 'togglePerguntas'
		text: 'Perguntas'
	}
	note: {
		icon: notes
		emit: 'toggleNotes'
		text: 'Anotações'
	}
	ai: {
		icon: ai
		emit: 'toggleAi'
		text: 'AI'
	}
	options: {
		icon: options
		emit: 'toggleOptions'
		text: 'Mais Opções'
	}
}

import './sentiment-pannel.imba'

tag interaction-bar

	prop selected = 'note'
	prop splitScreen

	css self 
			pos:absolute l:50% x:-50%
			o:0.8
			display: inline-flex;
			padding: 0.5rem 0.5rem;
			align-items: flex-start;
			gap: 0.5rem;	
			border-radius: 0.5rem;
			# background: var(--ui-container, #27232A);
			background: rgba(39, 35, 42, 0.5)
		.item
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: 0.5rem;
			cursor:pointer
			w:6rem
		.icon
			display: flex;
			width: 2rem;
			height: 2rem;
			padding: 0.5rem;
			flex-direction: column;
			justify-content: center;
			align-items: center;
			gap: 0.5rem;
			border-radius: 3.1875rem;
			background: #0B0B0B;
			&.selected
				border: 1px solid var(--apoio-verde, #5EB137);
		.text
			color: var(--principal-branco, #FFF);
			font-family: Poppins;
			font-size: 0.75rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%
			opacity: 0.8;
			text-align:center
		svg
			s:25px
			fill:var(--principal-branco, #ffffff)
			# stroke:var(--apoio-verde, #5EB137)
			&.selected
				fill:var(--apoio-verde, #5EB137)
				fill-opacity:1
				# stroke:var(--apoio-verde, #5EB137)

	def render
		<self>
			for own key, value of buttons
				<div.item @click=(emit(value.emit, !splitScreen); selected=key)>
					<div.icon .selected=(selected==key)>
						<svg .selected=(selected==key) src=value.icon>
					<div.text> value.text


