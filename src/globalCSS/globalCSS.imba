global css html
	ff:sans

global css html, body
	m:0 p:0
	h:100vh w:100vw
	color:#ffffff
	--navbarHeigth:50px
	# overflow-y: hidden

global css #editor
	size:500px pos:absolute l:50% x:-50% t:50% y:-50%

global css button, .btt, .button
	cursor:pointer

# # input placeholder
# global css
# 	::-webkit-input-placeholder, :-moz-placeholder, ::-moz-placeholder, :-ms-input-placeholder
# 		flex: 1 0 0;
# 		# color: var(--principal-branco, #FFF);
# 		font-family: Poppins;
# 		font-size: 1rem;
# 		font-style: normal;
# 		font-weight: 400;
# 		line-height: 150%
# 		# opacity: 0.5;

global css
	.input-container
		box-sizing: border-box
		display: vflex;
		# width: 24.75rem;
		align-items: flex-start;
		gap: 0.5em;
	.input-arandu
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
	.input-label
		all:unset
		align-self: stretch;
		color: var(--principal-branco);
		font-family: Poppins;
		font-size: 0.875em;
		font-style: normal;
		font-weight: 400;
		line-height: 150%;
		opacity: 0.8;

global css
	.button-arandu
		all:unset box-sizing: border-box d:flex p:8px jc:center ai:center g:8px flex-shrink:0
		w:26.375rem h:3rem
		border-radius:8px
		ff:var(--title-arandu) fs:16px font-style:normal line-height:150%
		bg:var(--laranja-arandu) @active:#E58320 c:var(--branco-arandu)
		cursor:pointer user-select:none		


global css 
	input[type=range]
		-webkit-appearance:none
	input[type=range]::-webkit-slider-runnable-track
			w:100%
			h:5px
			cursor:pointer
			animation-delay:0.2s
			background: #2497E3
			border-radius: 1px
			border: 0px solid #000000		
	input[type=range]::-webkit-slider-thumb
		shadow:0px 0px 0px #000000
		bd:1px solid #2497E3
		size:18px
		rd:25px
		background: #A1D0FF
		cursor: pointer
		-webkit-appearance: none
		margin-top: -7px
	input[type=range]@focus::-webkit-slider-runnable-track
		background: #2497E3
	input[type=range]::-moz-range-track
		w: 100%
		h: 5px
		cursor: pointer
		animate: 0.2s
		shadow: 0px 0px 0px #000000
		background: #2497E3
		rd: 1px
		bd: 0px solid #000000
	input[type=range]::-moz-range-thumb
		shadow: 0px 0px 0px #000000
		bd: 1px solid #2497E3
		h: 18px
		w: 18px
		rd: 25px
		background: #A1D0FF
		cursor: pointer



	input[type=range]::-ms-track
		width: 100%;
		height: 5px;
		cursor: pointer;
		animate: 0.2s;
		background: transparent;
		border-color: transparent;
		color: transparent;

	input[type=range]::-ms-fill-lower
		background: #2497E3;
		border: 0px solid #000000;
		border-radius: 2px;
		box-shadow: 0px 0px 0px #000000;

	input[type=range]::-ms-fill-upper
		background: #2497E3;
		border: 0px solid #000000;
		border-radius: 2px;
		box-shadow: 0px 0px 0px #000000;

	input[type=range]::-ms-thumb 
		margin-top: 1px;
		box-shadow: 0px 0px 0px #000000;
		border: 1px solid #2497E3;
		height: 18px;
		width: 18px;
		border-radius: 25px;
		background: #A1D0FF;
		cursor: pointer;

	input[type=range]:focus::-ms-fill-lower 
		background: #2497E3;

	input[type=range]:focus::-ms-fill-upper 
		background: #2497E3;
