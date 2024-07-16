import { auth } from '../firebase.imba'

# import logo from '../assets/icons/arandu-logo.svg'
# import name from '../assets/icons/arandu-name.svg'
import lupa from '../assets/icons/arandu-lupa.svg'
import bell from '../assets/icons/arandu-bell.svg'

import "./user-menu.imba"

# import {firestoreDB} from '@/firebase.imba'

tag nav-bar

	prop user
	prop showUserMenu = false
	prop showSidebar

	css self
			box-sizing: border-box
			w: 100%
			h:var(--navbarHeigth)
			flex-shrink: 0;
			d:flex
			ai:center
			jc:space-between
			background:#1E1A20
			box-shadow: 0px 4px 4px 0px rgba(0, 0, 0, 0.25);

	def render
		<self>
			if showUserMenu
				<user-menu user=user @hideUserMenu=(showUserMenu=false)>
				# <button.menuBtt @click=emit('toggleSidebar')>
				# 	<span .material-icons [fs:24px c:cool5]> 'menu'
			<logo route-to='/' color='#DE760C'>
			<a.streamBtt route-to='/stream/YqGlKsQOn8jrycuXRk7f'> "Stream" 
			<Search>
			<a.bttChannel route-to="{user.uid}/creator"> "Create" if user
			<User user=user @showUserMenu=(showUserMenu=!showUserMenu)>

tag Search

	css self
			box-sizing: border-box
			display: flex;
			width: 21.25rem;
			height: 2.5rem;
			justify-content: space-between;
			align-items: center;
			flex-shrink: 0;
		.container
			box-sizing: border-box
			m:4px
			display: flex;
			padding: 0.5rem 1rem;
			align-items: center;
			gap: 0.5rem;
			flex: 1 0 0;
			align-self: stretch;
			border-radius: 0.25rem;
			background: var(--ui-text-input, #413947);
		input
			all:unset
			flex: 1 0 0;
			color: var(--branco-arandu, #FFF);
			font-family: Poppins;
			font-size: 1rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%
			opacity: 0.5;
		svg
			width: 1.5rem;
			height: 1.5rem;

	<self>
		<div.container>
			<input type='text' placeholder='Buscar'>
			<svg src=lupa>

tag User

	prop user

	css self
			display: inline-flex;
			justify-content: flex-end;
			align-items: center;
			gap: 1rem;
			mr:1rem
		svg
			width: 1.5rem;
			height: 1.5rem;
			opacity: 0.9;
			cursor:pointer
		.container
			display: flex;
			align-items: center;
			gap: 0.5rem;
			cursor:pointer
		.username
			color: var(--branco-arandu, #FFF);
			text-align: right;
			font-family: Poppins;
			font-size: 0.80rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;

	<self>
		<svg src=bell>
		<div.container @click.if(user)=emit('showUserMenu')>
			if user
				<div.username> user.username ? user.username : 'Usuário'
				<div.user>
					<span .material-icons-round [fs:32px c:cool5]> 'account_circle'
			else
				<div>
					<button.loginBtt @click=emit('login', window.location.href) >
						<span .material-icons> 'login'