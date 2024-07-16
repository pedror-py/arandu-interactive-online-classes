# wtf.extend(require('wtf-plugin-html'))

import '../../../../sharedComponents/save-favorite-button.imba'

tag wiki-results

	prop doc

	css h:100% w:100% fs:0.75rem
		.title d:flex ai:center

	def render
		if doc
			<self>
				<div [px:0.3rem]>
					<div.title>
						<h4> doc.title()
						<save-favorite-button contentsData={type:'wikiResult', content:doc.title()}>
					for p of doc.sections()[0].paragraphs()
						<p [ta:justify]> p.text()
