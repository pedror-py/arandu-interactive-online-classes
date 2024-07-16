import "./perguntas.imba"
import "./free-chat.imba"
import "./notes-taker.imba"
import "./quickSearchComponents/search-results.imba"
import "./quickSearchComponents/ai-chat.imba"
import ai from "../../../assets/icons/ai-icon.svg"

tag stream-aux-sidebar

	prop user
	prop streamDoc
	prop show = false
	prop display = ''
	prop chatOpen = true
	prop txtSearch
	prop streamData

	css h:100% d:none w:22rem
		nav h:2.5rem d:flex w:100%
			button bgc:var(--ui-menu-lateral) bd:none c:var(--principal-branco)
			.selected bgc:sky7 bd:none c:var(--apoio-preto)
		section h:calc(100% - 2.5rem) w:100%
		.toggle w:5% cursor:pointer p:0
		.displayBtt p:0 w:20% w:calc(95% / 5) cursor:pointer
			d:vflex jc:center ai:center
		.bttName fs:0.75rem

	<self [d:block]=show>
		<nav>
			<button.toggle @click=(show=false)>
				<span .material-icons-outlined [fs:18px] > 'chevron_right'
			<button.displayBtt .selected=(display==='results') @click=(display='results') title='resultados'> 
				<span .material-symbols-outlined [fs:18px]> 'neurology'
				# <svg src=ai>
				<span.bttName> 'IA'
			<button.displayBtt .selected=(display==='perguntas') @click=(display='perguntas')> 
				<span .material-icons-outlined [fs:18px] > 'question_answer'
				<span.bttName> 'Perguntas'
			<button.displayBtt .selected=(display==='chat') @click=(display='chat') disabled=!chatOpen> 
				<span .material-icons-outlined [fs:18px] > 'chat'
				<span.bttName> 'Chat livre'
			<button.displayBtt .selected=(display==='notes') @click=(display='notes')> 
				<span .material-icons-outlined [fs:18px] > 'lightbulb'
				<span.bttName> 'Notas'
			<button.displayBtt .selected=(display==='content') @click=(display='content')> 
				<span .material-icons-outlined [fs:18px] > 'source'
				<span.bttName> 'Conteúdo'
		<section>
			switch display
				when 'perguntas'
					<perguntas 
					user=user
					streamDoc=streamDoc
					streamData=streamData
					>
				when 'chat'
					if chatOpen
						<free-chat 
							user=user
							streamId=streamDoc.id
							streamData=streamData
						>
					else
						<div [ta:center pt:50% fw:600 c:red4]> 'Chat fechado'
				when 'results'
					# <search-results txtSearch=txtSearch>
					<ai-chat
					user=user
					streamId=streamDoc.id
					streamData=streamData
					>
				when 'notes'
					<notes-taker streamData=streamData>
				when 'content'
					<stream-manager-timeline contentsData=streamData.contentsData streamer=false>