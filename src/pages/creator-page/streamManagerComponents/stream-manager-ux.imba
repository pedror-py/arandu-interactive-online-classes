

tag stream-manager-ux


	css self
			d:vflex
			w:100%
			h:100%
			bg:black
		.mainContainer
			w:100%
			h:calc(100% - 2rem)
			d:flex
			.left
				d:vflex
				h:100%
				w:calc(100% * (20 / 90))
				bg:green
			.center
				d:vflex
				h:100%
				w:calc(100% * (54 / 90))
				bg:blue
				.interactionBoxContainer
					w:100% h:75%
			.right
				h:100%
				d:vflex
				w:calc(100% * (16 / 90))
				bg:yellow
		.container

	def render
		<self>
			<streamer-top-bar>
			<div.mainContainer>
				<div.left>
					<left-box>
					<TransmissionPreview>
				<div.center>
					<div.interactionBoxContainer>
						<streamer-interaction-box>
					# <div.container>
					<stream-manager-dashboard>
				<div.right>
				# <stream-manager-timeline>



tag TransmissionPreview


	css self
			w:100%
			h:30%
			d:vflex
			jc:end
			ai:flex-end
			flex-shrink: 0
		.controls
			w:100%
			display: inline-flex;
			# box-sizing: border-box
			# padding: 0.5rem 0.975rem 0.85rem 1rem;
			justify-content: center;
			align-items: flex-start;
			gap: 10.7625rem;
			background: linear-gradient(180deg, rgba(0, 0, 0, 0.45) 0%, rgba(0, 0, 0, 0.00) 100%);
		.preview
			w:100% 
			aspect-ratio: 16 / 9
			bg:grey
			video
				pos:relative
				bg:black
				w:100%
			
	def render
		<self>
			<div.controls>
			<div.preview>
				<video>