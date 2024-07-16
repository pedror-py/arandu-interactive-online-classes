
tag stream-media-adder

	prop streamData
	prop displayContentType=''
	prop user

	css self h:100% w:100% d:flex jc:center
		add-content-pannel as:center
	<self
		# @addContent=addContent
		@newContent=(displayContentType=e.detail)
	>
		if !displayContentType
			<add-content-pannel displayContentType=displayContentType>
		else
			<div>
				<button @click=(displayContentType='')> 'voltar'
				<multimidia-planner
					streamData=streamData 
					displayContentType=displayContentType
					user=user
				>