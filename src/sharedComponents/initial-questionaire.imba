

const fieldsTest = [
	{
		fieldId:2
		fieldName:'boiologia'
		img:''
	}
	{
		fieldId:3
		fieldName:'mautematika'
		img:''
	}
]

tag initial-questionaire

	prop user
	prop questionaireData = {}
	prop userInfo = {}
	prop userInterests = []
	prop display = 'interests'
	prop fieldsList = fieldsTest
	

	def toggleInterest(e)
		const field = e.detail
		if userInterests.includes(field)
			const i = userInterests.indexOf(field)
			userInterests.splice(i, 1)
		else
			userInterests.push(e.detail)

	def save
		questionaireData = {userInfo, userInterests}
		# TODO: save questionaireData at firestore

	css self
		.background pos:absolute w:100vw h:100vh bgc:black/50 l:50% x:-50% t:50% y:-50%
		.mainContainer
			pos:absolute  mt:5px of:hidden l:50% x:-50% t:50% y:-50% zi:9999999999
			w:50% h:70% bgc:blue1 bd:1px solid black rd:15px p:10px

	def render
		console.log userInterests
		<self>
			<div.background>
				<div.mainContainer>
					<global @pointerdown.outside=emit('closePopUp')>
					<div>
						if display === 'form'
							<user-info-form>
						if display === 'interests'
							<interests-selection @toggleInterest=toggleInterest
								fieldsList=fieldsList
								userInterests=userInterests
							
							>
					<div.bottomButtons>
						<button> 'Próximo'

tag interests-selection

	prop fieldsList
	prop userInterests

	css self
		.container d:flex g:5px

	<self>
		<div.container>
			for item in fieldsList
				<field-item data=item selected=(userInterests.includes(item.fieldName))>


tag field-item

	prop data
	prop selected=false

	css self 
			bgc:warm0 s:100px bd:1px solid black

	<self @click=emit('toggleInterest', data.fieldName) [bgc:green4]=selected>
		<div> data.fieldName


tag user-info-form

	<self>
		<form>