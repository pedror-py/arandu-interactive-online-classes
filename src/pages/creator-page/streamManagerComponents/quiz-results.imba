import { collection, doc, getDoc, getDocs, setDoc, addDoc, onSnapshot, query, where, updateDoc, serverTimestamp } from 'firebase/firestore'
import { firestoreDB } from '../../../firebase.imba'

# answeredBy: "qC4ucvNb1sgARQ1UrMKFahmf16z1"
# contentType: "quiz"
# gotRight: true
# pergunta: "quem fez o q?"
# respostas:

# acertou: false
# index: 0
# letra: "a"
# respostaCorreta: false
# selected: true
# txtResposta: "fulano"


tag quiz-results

	prop streamId
	prop streamData
	prop quizContent
	prop results = {}
	prop atQuiz = false
	# prop unsubscribe = null

	def awaken

	def listenToAnswers
		for res, i of quizContent.respostas
			results[i] = 0
		const quizCollection = collection(firestoreDB, "streams/{streamId}/quizes/{quizContent.quizId}/answers")
		unsubscribe = onSnapshot(quizCollection, do(snapshot)
			snapshot.docChanges().forEach do(change)
				if change.type === 'added'
					const data = change.doc.data()
					const {answerIndex} = data
					results[answerIndex] += 1
		)

	# const interval = setInterval(&, 3000) do()
	# 	const answerDocs = await getDocs(quizCollection)
	# 	for doc in answerDocs
	# 		const data = doc.data()
	# 		const {answerIndex} = data
	# 		results[answerIndex] += 1


	css self
		.results ff:Poppins, sans-serif px:10px
		.pergunta mb:10px font-size:1rem
		.respostasContainer bdt:1px solid black pt:10px
		.resposta d:flex ai:center mb:10px font-size:0.8rem
		.count bgc:#f1f1f1 rd:4px p:6px 12px ml:auto
		span fw:bold c:black

	def render
		if streamData.contentsData.length
			if streamData.contentsData[streamData.streamStates.contentIndex].contentType === 'quiz'
				atQuiz = true
				quizContent = streamData.contentsData[streamData.streamStates.contentIndex]
				if !unsubscribe
					listenToAnswers()
			else
				atQuiz = false

		<self [h:90%]>
			if atQuiz
				<div.results>
					<div.perguntaContainer>
						<div.pergunta> quizContent.pergunta
					<div.respostasContainer>
						for resposta, i of quizContent.respostas
							<div.resposta> 
								<div> resposta.txtResposta
								<div.count>
									<span> results[i]
			else
				<button.newQuizBtt @click=emit('newQuiz')> 'Criar uma nova quiz'