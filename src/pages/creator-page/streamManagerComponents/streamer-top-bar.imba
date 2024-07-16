import menu from '../../../assets/icons/menu-icon.svg'
import play from '../../../assets/icons/play-button-icon.svg'
import edit from '../../../assets/icons/edit-button-icon.svg'
import stop from '../../../assets/icons/stop-icon.svg'
import share from '../../../assets/icons/share-button.svg'


tag streamer-top-bar

	prop user
	prop live = !false
	prop streamData
	prop bitrateSum = 0

	def getBitrate
		if live
			const intervalId = setInterval(&, 1000) do
				for own media, value of medias
					for own type, producer of value.producers
						if producer
							const stats = await producer.getStats()
							if stats && stats.length > 0
								const bitrate = stats[0].bitrate

	css self
			d:flex
			ai:center
			box-sizing: border-box
			w:100%
			height: 2.5rem
			flex-shrink: 0
			border: 1px solid #303030;
			background: var(--ui-container, #27232A);
			box-shadow: 0px 4px 4px 0px rgba(0, 0, 0, 0.10);
			.streamInfo
			.share
			ff:Poppins
		.liveBall
			rd:50%
			background: #D92424
			s:0.7rem
		.box
			d:flex ai:center jc:center g:1rem ml:auto mr:1rem
		.liveBox
			d:flex ai:center g:5px
		.live
			line-height: 150%
			fs:0.8rem
		.edit
			font-family:Poppins
			fs:0.7rem
			c:white
			display: flex;
			bd:none
			padding: 0.25rem 0.5rem;
			align-items: flex-end;
			gap: 0.5rem;
			border-radius: 0.25rem;
			background: #535353;
			d:flex
			ai:center
		.editSvg
			s:12px
		.offline
			o:0.4
		.startStreamButton
			d:flex ai:center
		.share
			font-family:Poppins
			fs:0.7rem
			c:white
			display: flex;
			bd:none
			padding: 0.25rem 0.5rem;
			align-items: flex-end;
			gap: 0.5rem;
			border-radius: 0.25rem;
			background: #535353;
			d:flex
			ai:center
			svg
				s:20px
		.toggleSidebar
			m:0 2rem 0 1rem

	def render

		<self>
			<svg .btt .toggleSidebar src=menu @click=emit('toggleSidebar')>

			<div.share.btt @click=emit('shareLink')>
				<div> 'Compartilhar'
				<svg src=share>
			
			<div.streamInfo>
				# <div.title> "Título: {streamData.title || '-----'}"
				<div.bitrate> "Taxa de bits: {bitrateSum} Kbps" if live

			<div.box>
				<div>
					<button @click=emit('record')> 'record'
				<div.liveBox>
					if live
						<div.liveBall>
					<div.live .offline=!live> live ? 'AO VIVO' : 'Offline'
				<div.startStreamButton .button @click=emit('startStream')>
					<svg.playSvg [s:30px] src=(live ? stop : play)>
				<button.edit @click=emit('editStreamData')>
					<svg.editSvg fill='white' src=edit>
					<div> 'Editar dados de transmissão'
			# <button route-to="/{user.uid}/creator/selection/manager"> 'voltar'
