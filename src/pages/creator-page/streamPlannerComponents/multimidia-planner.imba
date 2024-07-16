import "./addContentComponents/yt-video-adder.imba"
import "./addContentComponents/video-adder.imba"
import "./addContentComponents/quiz-maker.imba"
import "./addContentComponents/pdf-adder.imba"
import "./addContentComponents/slides-adder.imba"
import "./addContentComponents/website-adder.imba"
import "./addContentComponents/img-adder.imba"
import "./addContentComponents/code-editor-adder.imba"

tag multimidia-planner

	prop iframe = null
	prop displayContentType
	prop streamData
	prop contentToEdit
	prop user

	css self 
			h:100% w:100%

	def render
		<self>
			switch displayContentType
				when ''
					<h1 [c:red4]> 'Adicione um conteúdo'
				when 'quiz'
					<quiz-maker editing=contentToEdit>
				when 'YT'
					<yt-video-adder editing=contentToEdit iframe=iframe>
				when 'video'
					<video-adder editing=contentToEdit user=user videoElement=iframe>
				when 'pdf'
					<pdf-adder editing=contentToEdit user=user iframe=iframe>
				when 'img'
					<img-adder editing=contentToEdit user=user>
				when 'slide'
					<slides-adder editing=contentToEdit streamData=streamData iframe=iframe>
				when 'website'
					<website-adder editing=contentToEdit iframe=iframe>
				when 'editor'
					<code-editor-adder editing=contentToEdit iframe=iframe>