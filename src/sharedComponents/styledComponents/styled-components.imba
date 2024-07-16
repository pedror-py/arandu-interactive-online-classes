import logo from '../../assets/icons/arandu-logo.svg'
import name from '../../assets/icons/arandu-name.svg'

tag button-arandu < button

	prop text
	prop svg = ''
	prop preIcon = false

	css self
			all:unset box-sizing: border-box d:flex p:8px jc:center ai:center g:8px flex-shrink:0
			w:26.375rem h:3rem
			border-radius:8px
			ff:var(--title-arandu) fs:16px font-style:normal line-height:150%
			bg:var(--laranja-arandu) @active:#E58320 c:var(--branco-arandu)
			cursor:pointer user-select:none

		svg
			width: 1.5rem;
			height: 1.5rem;
			flex-shrink: 0;

	<self.button
		# [all:unset box-sizing: border-box d:flex p:8px jc:center ai:center g:8px flex-shrink:0]
		# [w:26.375rem h:3rem]
		# [border-radius:8px]
		# [ff:var(--title-arandu) fs:16px font-style:normal line-height:150%]
		# [bg:var(--laranja-arandu) @active:#E58320 c:var(--branco-arandu)]
		# [cursor:pointer user-select:none]
		[outline@blur:none outline-offset@focus:2px]
		tabindex='0'
	> 
		if !preIcon
			<div> text
			if svg
				<svg src=svg>
		else
			if svg
				<svg src=svg>
			<div> text



tag input-arandu

	prop value = ''
	prop label = 'Label'
	prop placeholder = 'Placeholder'
	prop type='text'
	prop required=false
	prop name

	css self
			box-sizing: border-box
			display: vflex;
			# width: 24.75rem;
			align-items: flex-start;
			gap: 0.5em;
		label
			all:unset
			align-self: stretch;
			color: var(--principal-branco);
			font-family: Poppins;
			font-size: 0.875em;
			font-style: normal;
			font-weight: 400;
			line-height: 150%;
			opacity: 0.8;
		input
			all:unset
			box-sizing: border-box
			display: flex;
			width:100%
			height: 3em;
			padding:0.5em 1em;
			align-items: center;
			gap: 0.5em;
			border-radius: 0.3125rem;
			background: var(--ui-text-input, #413947);
			color:rgba(225,225,225, 0.5)
			font-family: Poppins;
			font-size: 1em;
			font-style: normal;
			font-weight: 400;
			line-height: 150%
			color: var(--principal-branco)

	def render
		<self [g:0]=!label>
			<label> label
			<input placeholder=placeholder type=type bind=value required=required name=name>

tag select-arandu

	prop value
	prop label = 'Label'
	prop placeholder = 'Placeholder'
	prop options = ['Opção 1', 'Opção 2']

	css self
			pos:relative
			box-sizing: border-box
			display: flex;
			width: 24.75rem;
			flex-direction: column;
			align-items: flex-start;
			gap: 0.5rem;
		label
			all:unset
			align-self: stretch;
			color: var(--branco-arandu, #FFF);
			font-family: Poppins;
			font-size: 0.875rem;
			font-style: normal;
			font-weight: 500;
			line-height: 150%;
			opacity: 0.8;
		select
			all:unset
			pos:relative
			box-sizing: border-box
			display: flex;
			width: 100%
			height: 3rem;
			padding:0.5rem 1rem;
			align-items: center;
			gap: 0.5rem;
			border-radius: 0.3125rem;
			background: var(--ui-text-input, #413947);
			color:rgba(225,225,225, 0.5)
			font-family: Poppins;
		option
			box-sizing: border-box
			display: flex;
			height: 3rem;
			padding:0.5rem 1rem;
			align-items: center;
			gap: 0.5rem;
			border-radius: 0.3125rem;
			background: var(--ui-text-input, #413947);
			color:rgba(225,225,225, 0.5)
			font-family: Poppins;
			font-size: 1rem;
			font-style: normal;
			font-weight: 400;
			line-height: 150%
		svg
			width: 1.5rem;
			height: 1.5rem;
			flex-shrink: 0;
			pos:absolute
			color:rgba(225,225,225, 0.5)
			t:41px
			r:0.5rem
			pointer-events:none

	<self>
		<label> label
		<select placeholder=placeholder bind=value>
			for option of options
				<option value=option> option
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
			<path d="M6.451 9.18177C6.38736 9.12163 6.31249 9.07461 6.23067 9.0434C6.14885 9.01219 6.06168 8.9974 5.97415 8.99987C5.88661 9.00235 5.80042 9.02204 5.7205 9.05783C5.64058 9.09361 5.56848 9.14479 5.50834 9.20844C5.44819 9.27209 5.40117 9.34696 5.36996 9.42878C5.33875 9.51059 5.32396 9.59776 5.32644 9.68529C5.32891 9.77283 5.34861 9.85902 5.38439 9.93894C5.42018 10.0189 5.47136 10.091 5.535 10.1511L11.535 15.8178C11.6588 15.9348 11.8227 16 11.993 16C12.1633 16 12.3272 15.9348 12.451 15.8178L18.4517 10.1511C18.5167 10.0914 18.5692 10.0193 18.6062 9.93906C18.6431 9.85884 18.6638 9.77208 18.6669 9.68382C18.67 9.59556 18.6556 9.50755 18.6244 9.42491C18.5933 9.34228 18.546 9.26665 18.4854 9.20244C18.4247 9.13823 18.3519 9.0867 18.2712 9.05086C18.1905 9.01501 18.1035 8.99556 18.0152 8.99364C17.9269 8.99172 17.8391 9.00736 17.7569 9.03965C17.6747 9.07195 17.5997 9.12026 17.5363 9.18177L11.993 14.4164L6.451 9.18177Z" fill="white"/>

tag logo

	prop color
	prop vertical=false

	css self
			display: inline-flex;
			align-items: center;
			gap: 0.21913rem;
			ml:1rem
			cursor:pointer
			color:var(--laranja-arandu)
		&.vertical
			d:vflex
		.logo
			width: 2.51863rem;
			height: 1.57788rem;
		.name
			width: 6.01219rem;
			height: 1.36669rem;
		

	<self .vertical=vertical>
		<svg.logo src=logo fill=color>
		<svg.name src=name fill=color>

tag modal

	css self
			pos:fixed
			t:0 l:0 r:0 b:0
			d:flex ai:center jc:center
			w:100vw
			h:100vh
			zi:99999
			bgc:black/50

tag css-test

	<self>
		<button-arandu text='Continuar'>
		<input-arandu>
		<select-arandu>

