# wtf.extend(require('wtf-plugin-html'))

const parser = new DOMParser()

tag dict-results

	prop doc

	css h:100% w:100% fs:0.75rem

	def render
		if doc
			<self>
				<div> 
				for section of doc.sections()
					let title = section.title()
					let text = section.text()
					<h5 [m:0]> title
					<p [m:0]> text
					# let html = section.html()
					# let c = parser.parseFromString(html, 'text/html')
					# <div> c.body
