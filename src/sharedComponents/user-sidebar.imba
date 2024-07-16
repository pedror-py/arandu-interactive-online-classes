
import menu from '../assets/icons/menu-icon.svg'
import closeMenu from '../assets/icons/close-menu.svg'
import home from '../assets/icons/home-icon.svg'
import subs from '../assets/icons/subscriptions-icon.svg'
import savedContent from '../assets/icons/saved-content-icon.svg'
import clips from '../assets/icons/clips-icon.svg'
import manager from '../assets/icons/stream-manager-icon.svg'
import plan from '../assets/icons/plan-stream-icon.svg'
import personalizar from '../assets/icons/personalizar-icon.svg'
import content from '../assets/icons/content-icon.svg'
import analytics from '../assets/icons/analytics-icon.svg'
import monetization from '../assets/icons/monetization-icon.svg'
import config from '../assets/icons/config-icon.svg'

const userButtons = {
	home: {
		btt: "Home"
		route:'home'
		icon: home
	}
	subscriptions: {
		btt: "Inscrições"
		# route:"/{user.uid}/subscriptions"
		route:"subscriptions"
		icon: subs
	}
	saved: {
		btt: "Conteúdos salvos"
		# route:"/{user.uid}/saved"
		route:"saved"
		icon: savedContent
	}
	clips: {
		btt: "Clipes"
		# route:"/{user.uid}/clips"
		route:"clips"
		icon: clips
	}
}

const creatorButtons = {
	inicio: {
		btt: "Início"
		route:'creator/inicio'
		icon:home
	}
	manager:{
		btt: "Stream manager"
		route:'creator/selection/manager'
		# route:'./stream-manager/selection'
		icon:manager
	}
	planStream:{
		btt: "Plan Stream"
		route:'creator/selection/plan'
		# route:'./plan/selection'
		icon:plan
	}
	personalizar:{
		btt:"Personalizar"
		route:'creator/editing'
		icon:personalizar
	}
	content:{
		btt: "Conteúdo"
		route:'creator/contents'
		icon:content
	}
	analytics:{
		btt: "Analytics"
		route:'creator/analytics'
		icon:analytics
	}
	monetization:{
		btt: "Monetização"
		route:'creator/monetization'
		icon:monetization
	}
	config:{
		btt: "Configurações"
		route:'creator/config'
		icon:config
	}
}

tag user-sidebar

	prop user
	prop userDoc
	prop colapsed = !false
	prop creator = false
	prop buttons = userButtons
	prop streamManager = false
	# prop currentPath

	css self
			# box-sizing: border-box
			display: flex;
			width: 13.0625rem;
			height: 59.5625rem;
			padding: 3.5rem 0.5rem 2.125rem 0.25rem;
			flex-direction: column;
			align-items: flex-start;
			gap: 3rem;
			flex-shrink: 0;
			background: #27222B
			pos:fixed
			zi:1
			&.colapsed
				display: vflex;
				width: var(--navbarHeigth)
				height: 76rem;
				# padding: 3.5rem 2rem 1rem 2rem;
				# justify-content: center;
				align-items: flex-start;
				gap: 0.5rem;
				flex-shrink: 0;
			&.none
				d:none
		.colapseBtt
			all:unset
			width: 1.5rem;
			height: 1.5rem;
			position: absolute;
			right: 1.0625rem;
			top: 1.125rem;
			cursor:pointer
		.expandBtt
			all:unset
			width: 1.5rem;
			height: 1.5rem;
			position: absolute;
			left:calc(50% - 12px);
			t:1rem
			cursor:pointer

	def render

		<self .colapsed=colapsed
		[d:none]=(streamManager && colapsed)
		>
			if colapsed

				<button.expandBtt @click=emit('toggleSidebar')>
					<svg src=menu>
			else
				<button.colapseBtt @click=emit('toggleSidebar')>
					<svg src=closeMenu>
			<Buttons colapsed=colapsed user=user>
			if !colapsed && !creator
				<Subscriptions userDoc=userDoc>



tag Buttons

	prop user
	prop buttons
	prop colapsed
	# prop route = '/'

	css self
			display: flex;
			flex-direction: column;
			align-items: flex-start;
			gap: 1rem;
			align-self: stretch;
			&.colapsed
				# display: flex;
				# width: 1.75rem;
				flex-direction: column;
				align-items: center;
				gap: 1.5rem;
				# flex-shrink: 0;
		button
			all:unset
			display: flex;
			padding: 0.25rem 1rem;
			align-items: center;
			gap: 0.5rem;
			align-self: stretch;
			border-radius: 0.25rem;
			cursor:pointer
			&.colapsed
				jc:center
				align-self: center;
				w:1.5rem
				padding: 0.25rem;
				gap: 0.25rem;
		svg
			width: 1.25rem;
			height: 1.25rem;
		.text
			color: #ffffff;
			text-align: right;
			font-family: Poppins;
			font-size: 0.875rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;			

	def render
		if imba.router.path.includes('creator')
			buttons = creatorButtons
		else
			buttons = userButtons

		<self .colapsed=colapsed>
			for own key, value of buttons
				if user
					<button .colapsed=colapsed
						[background:rgba(255, 255, 255, 0.10)]=(selected===key) 
						[background:rgba(255, 255, 255, 0.10)]=(imba.router.path.includes(key)) 
						# route-to=value.route
						# route-to='./selection/manager'
						route-to="/{user.uid}/{value.route}"
						@click=(selected=key)
					> 
						<svg src=value.icon>
						if !colapsed
							<div.text [d:none]=colapsed> value.btt
				else
					<button .colapsed=colapsed
						# route-to="/log-in"
						@click=emit('login')
					> 
						<svg src=value.icon>
						if !colapsed
							<div.text [d:none]=colapsed> value.btt



tag Subscriptions

	prop userDoc

	css self
			display: flex;
			padding: 0rem 1rem;
			flex-direction: column;
			align-items: flex-start;
			gap: 1rem;
			align-self: stretch;
		.title
			color: var(--principal-laranja, #E58320);
			font-family: Poppins;
			font-size: 0.875rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;
		.list
			display: flex;
			flex-direction: column;
			align-items: flex-start;
			gap: 1rem;
			align-self: stretch;
		.buttons
			display: flex;
			justify-content: space-between;
			align-items: flex-start;
			align-self: stretch;
			.text
				color:#ffffff
				font-family: Poppins;
				font-size: 0.75rem;
				font-style: normal;
				font-weight: 400;
				line-height: 150%;
				text-decoration-line: underline;
				cursor:pointer

	<self>
		<div.title> "Inscrições"
		<div.list>
			if userDoc
				for channel of userDoc.data().subscriptions 
					<ChannelButton channel=channel> channel
		<div.buttons>
			<div.text> 'Menos'
			<div.text> 'Mais'


tag ChannelButton

	prop channel
	prop live = true

	css self
			display: flex;
			align-items: center;
			gap: 0.625rem;
			align-self: stretch;
			cursor:pointer
		img
			width: 2rem;
			height: 2rem;
			border-radius: 2rem;
			# bgc:grey
			border: 1px solid var(--vermelho--arandu, #C22);
			# background: url(<path-to-image>), lightgray 50% / cover no-repeat, url(<path-to-image>), lightgray 50% / cover no-repeat, #D9D9D9;
		.name
			color: #ffffff;
			font-family: Poppins;
			font-size: 0.875rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;
		.live
			display: flex;
			align-items: center;
			gap: 0.375rem;
			align-self: stretch;
		.redDot
			width: 0.5rem;
			height: 0.5rem;
			border-radius: 1.6875rem;
			background: #D92424;
		.liveText
			font-family: Poppins;
			font-size: 0.75rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;	


	<self  route-to="/channel/{channel}">
		<img>
		<div>
			<div.name> channel
			if live
				<div.live>
					<div.redDot>
					<div.liveText> 'AO VIVO'
