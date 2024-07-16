import presentation from '../../../assets/icons/presentation-icon.svg'
import youtube from '../../../assets/icons/youtube-icon.svg'
import quiz from '../../../assets/icons/quiz-icon-2.svg'
import website from '../../../assets/icons/website-icon.svg'
import code from '../../../assets/icons/code-editor-icon.svg'
import pdf from '../../../assets/icons/pdf-icon.svg'

tag stream-manager-timeline
	
	prop contentsData
	prop currentIndex = 0
	prop streamer = true

	def changeCurrentContent(type)
		if type === "previous"
			currentIndex = Math.max(0, currentIndex - 1)
		elif type === "next"
			currentIndex = Math.min(contentsData.length - 1, currentIndex + 1)
		else
			currentIndex = type
		emit('contentChange', currentIndex)

	css h:100% w:100% d:vflex ai:center bgc:#27232A
		.buttonsContainer d:flex g:30px mt:auto
		.timelineContainer w:100% h:90% d:vflex g:1px ai:center of:auto
		.addMediaBtt my:5px h:40px rd:lg bgc:#660E37 c:white

	<self @changeCurrentContent=changeCurrentContent(e.detail)>
		<h4 [m:1px]> "Conteúdos interativos"
		# <div.buttonsContainer>
		# 	<button type="button" @click=changeCurrentContent('previous')> "Anterior"
		# 	<button type="button" @click=changeCurrentContent('next')> "Próximo"
		<div.timelineContainer>
			if streamer
				<button.addMediaBtt @click=emit('addMedia')> 
					<span> "Adicionar media"
					<div>
						<span .material-icons-outlined [c:green4 fs:18px]> 'add'
				
			if contentsData
				# <div [w:50px h:1.2rem bgc:orange4 as:center ta:center]> "Início"
				for item,index of contentsData
					if item
						if (item.contentType != 'quiz') && !streamer
							<stream-content-item 
								item=item 
								index=index
								currentContent=(index === currentIndex)
								streamer=streamer
							>
							<div [h:5px]>
						if streamer
							<stream-content-item 
								item=item 
								index=index
								currentContent=(index === currentIndex)
								streamer=streamer
							>
							<div [h:5px]>
				# <div [w:50px h:1.2rem bgc:orange4 as:center ta:center]> "Fim"


tag stream-content-item
	prop item
	prop index
	prop currentContent = false
	prop text = ''
	prop icon
	prop streamer

	css h:50px w:90% font-family:Poppins
		.contentBlock
			w:100% h:100% bgc:#222222 p:0.2em rd:6px d:vflex jc:start c:white
		cursor:pointer
		# @hover size:80px bgc:green4
	# css .deleteBtt fs:0.7rem m:0 mt:auto 
	# 	@hover td:underline cursor:pointer
	
	def render
		if currentContent
			self.scrollIntoView({inline:'center'})
		switch item.contentType
			when 'slide'
				text="Apresentação de slides"
				icon=presentation
			when 'YT'
				text="Video do Youtube"
				icon=youtube
			when 'quiz'
				text="Quiz"
				icon=quiz
			when 'website'
				text="Website externo"
				icon=website
			when 'codeEditor'
				text="Editor de código"
				icon=code
			when 'pdf'
				text="PDF"
				icon=pdf

		# if !streamer && item.contentType == 'quiz'
		# 	unmount()
		# else
		<self>
			<button.contentBlock  
				@click=emit('changeCurrentContent', index) 
				[bgc:green4  c:black]=currentContent 
				disabled=(!streamer && item.contentType == 'quiz')
				>
				# <span [as:center m:0]> "{item.contentType}"
				<svg src=icon [s:20px]>
				<span [as:center m:0]> text