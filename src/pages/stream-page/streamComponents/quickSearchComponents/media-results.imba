# wtf.extend(require('wtf-plugin-image'))

tag media-results

	prop doc

	css h:100% w:100% fs:0.75rem

	def render
		
		if doc
			let images = doc.images()
			<self>
				<img src='https://upload.wikimedia.org/wikipedia/commons/c/c3/Pinturas_Rupestres_-_Serra_da_Capivara_I.jpg'>
				console.log images[0].url()
				let url = images[0].commonsURL()
				console.log url
				if url
					<img src=url>
				# for image of images
				# 	let url = image.commonsURL()
				# 	<img src=url>


