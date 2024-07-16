const contents = {
	inicio: {
		btt: "Início"
		route:'./inicio'
		icon:'home'
	}
	manager:{
		btt: "Stream manager"
		route:'./selection/manager'
		# route:'./stream-manager/selection'
		icon:'stream'
	}
	planStream:{
		btt: "Plan Stream"
		route:'./selection/plan'
		# route:'./plan/selection'
		icon:'schema'
	}
	personalizar:{
		btt:"Personalizar"
		route:'./editing'
		icon:'brush'
	}
	content:{
		btt: "Conteúdo"
		route:'./contents'
		icon:'subscriptions'
	}
	analytics:{
		btt: "Analytics"
		route:'./analytics'
		icon:'analytics'
	}
	monetization:{
		btt: "Monetização"
		route:'./monetization'
		icon:'monetization_on'
	}
	config:{
		btt: "Configurações"
		route:'./config'
		icon:'settings'
	}
}

tag creator-sidebar-menu

	prop user
	prop channels
	prop selectedChannel
	prop show = false

	css self h:100%
		.container
			bgc:cool8 w:8rem h:100%
			d:vflex g:0.25rem flg:0 fls:0
		.toggle as:flex-end
		.displayBtn w:100% h:3rem p:0
			d:flex ai:center g:0.2rem
		.material-icons-outlined fw:300
		
	def render
		<self>
			<div [w:2rem]=show>
			<div.container
				[w:2rem]=!show [pos:fixed]=show
			>
				<global  @pointerdown.outside.if(show)=emit('toggleSidebar')>
				<button.toggle @click=(emit('toggleSidebar'))>
					<span .material-icons-outlined [fs:18px] > 'chevron_left' if show
					<span .material-icons-outlined [fs:18px] > 'chevron_right' if !show
				<div [d:vflex ai:center g:5px]>
					<img [w:30px] [w:80px]=show src="https://avatars.dicebear.com/api/identicon/{selectedChannel.channelId}.svg">
					if show
						<select>
							for channel of channels
								<option value=channel.channelName> channel.channelName
				for own key, value of contents
					<button.displayBtn 
					@click=(do emit('toggleSidebar') if !show)
					@click=(do emit('inPlanner', key=='planStream') if (key == 'manager' || key == 'planStream'))
					route-to=value.route 
					[jc:center]=!show
					>
						<span .material-icons-outlined [fs:18px] [fs:24px]=!show> value.icon
						<span [d:none]=!show> value.btt
