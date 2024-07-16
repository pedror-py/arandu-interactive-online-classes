import { auth } from '../firebase.imba'

tag user-menu

	prop user

	css pos:absolute bgc:blue1 rd:lg zi:5000
		w:11rem max-height:calc(100vh - 5rem)
		transform: translate(calc(100vw - 11.5rem), 3.5rem)
		.container d:vflex p:.5em
		.item d:flex g:5px py:0.2em ai:center cursor:pointer pl:0.2rem
			@hover bgc:cool4
		.signOutBtn p:2px ml:auto d:flex g:2px ai:center
		.icon fs:18px
		
	<self>
		<global @click.outside=(emit('hideUserMenu'))>
		<div.container>
			<div.item> "{user.displayName}"
			<hr>
			<div.item> "Canal"
				<a>
			<div.item route-to="{user.uid}/creator/inicio"> 
				<span.icon .material-icons-outlined> 'videocam'
				<span> "Estúdio de vídeo"
			<div.item> 
				<span.icon .material-icons-outlined> 'tune'
				<span> "Painel de controle"
			<div.item> 
				<span.icon .material-icons-outlined> 'settings'
				<span> "Configurações"
			<div.item> 
				<span.icon .material-icons-outlined> 'dark_mode'
				<span> "Tema escuro"
			<div>
				<button.signOutBtn @click=emit('signOut')> 
					<span> "Log out"
					<span.icon .material-icons-outlined> 'logout'

# (do auth.signOut(); imba.commit())