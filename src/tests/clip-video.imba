import { httpsCallable } from "firebase/functions"
import { ref, getDownloadURL, getBlob  } from "firebase/storage"

import { functions, storage } from "../firebase.imba"
# const videoUrl = "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"

tag clip-video

	prop clipStart = 85
	prop clipEnd = 100
	prop videoBlob
	prop clipData = {
			videoSrc: $video.src
			videoStoragePath: 'streams/JA6FZkpZhDTCgug25EG1'
			vodID: '001'
		}

	css video w:500px pos:absolute t:150px l:50% x:-50%
	css	timeline-view pos:absolute t:500px l:50% x:-50%

	def awaken
		const videoRef = ref(storage, clipData.videoStoragePath)
		videoBlob = await getBlob(videoRef)
		videoUrl = await getDownloadURL(videoRef)
		console.log videoBlob
		$video.src = videoUrl
		# $video.src = URL.createObjectURL(videoBlob)

	def clipVideo(time)
		clipEnd = $video.currentTime
		clipStart = Math.max(0, clipEnd - time)
		clipData = {
			...clipData
			videoSrc: $video.src
			clipStart
			clipEnd
		}

	def updateClip(e)
		{clipStart, clipEnd} = e.detail
		clipData = {...clipData, clipStart, clipEnd}
		$video.play()
		
	def startClip(e)
		console.log e
		# $video.loaded = true
		# console.log($video.duration )
		# $video.currentTime = clipStart * $video.duration / 100 
		# $video.play()

	def createClip
		console.log 'creating clip...'
		clipData.start = $video.duration * clipStart / 100
		clipData.end = $video.duration * clipEnd / 100
		clipData.clipDuration = clipData.end - clipData.start
		const cutVideo = httpsCallable(functions, 'cutVideo')
		cutVideo(clipData).then(do(result)
			const data = result.data;
			console.log data
			const fileRef = ref(storage, data.filePath)
			getDownloadURL(fileRef).then do(res)
				console.log res
		)
		
	<self 
	# @restart=startClip
	>
		<video$video controls muted 
		@loadedmetadata=startClip
		>
		<timeline-view 
			video=$video 
			contentsData=clipData 
			clipStart=clipStart
			clipEnd=clipEnd
			@updateClip=updateClip
		>
		<button @click=clipVideo(10)> "Salvar 10s"
		<button @click=clipVideo(30)> "Salvar 30s"
		<cut-video>
		# <Panel>
		# <button @click=clipVideo(60)> "Salvar 1m"
		# <button @click=clipVideo(120)> "Salvar 2m"
		# <button @click=clipVideo(300)> "Salvar 5m"

tag timeline-view
	
	prop video\HTMLVideoElement
	prop width= 500
	prop autorender = 60fps
	prop clipStart
	prop clipEnd

	css size:30px bgc:cooler4 d:dlex
		.track bgc:rose4 w:4px h:calc(100% + 4px) zi:10
			pos:absolute t:-2px l:-2px

	def render
		let playheadPercentage = video.currentTime / video.duration
		let playheadPosition = playheadPercentage * width
		if (playheadPercentage >= clipEnd/100) or (playheadPercentage < clipStart/100)
			emit('restart')
		<self[d:flex h:50px w:{width}px]>
			# console.log clipStart, clipEnd
			<div[bg:teal2 flex-basis:{clipStart}%]>
			<div[fls:0 w:2 bg:teal3 @touch:teal5]
				@touch.fit(self,0,100,0.2)=emit('updateClip', {clipStart:e.x, clipEnd})>
			<div[bg:teal4 flex:1]>
				<div.track.currentPos [d:none x:{playheadPosition}px] [d:block]=(video.loaded) >
			<div[fls:0 w:2 bg:teal8 @touch:teal9]
				@touch.fit(self,0,100,0.2)=emit('updateClip', {clipStart, clipEnd:e.x})>
			<div[bg:teal1 flex-basis:{100-clipEnd}%]>

tag Panel
	startPos = 50
	endPos = 90

	def render
		<self[d:flex h:50px w:200px]>
			# console.log startPos, endPos
			<div[bg:teal2 flex-basis:{startPos}%]>
			<div[fls:0 w:1 bg:teal3 @touch:teal5]
				@touch.fit(self,0,100,0.2)=(startPos=e.x)>
			<div[bg:teal1 flex:1 min-width:10px]>
			<div[fls:0 w:1 bg:teal8 @touch:teal9]
				@touch.fit(self,0,100,0.2)=(endPos=e.x)>
			<div[bg:teal1 flex-basis:{100-endPos}%]>


# -------------AXIOS HTTP REQUEST-----------
# import axios from 'axios'

# tag cut-video-axios

# 	prop duration = 2

# 	def send
# 		axios.post("http://localhost:8080/clip", {message:'hello', duration})
# 			.then(do(response) console.log(response.data))
# 			.catch(do(error) console.error(error))

# 	<self>

# 		<input type='text' bind=duration>
# 		<button @click=send> 'send'