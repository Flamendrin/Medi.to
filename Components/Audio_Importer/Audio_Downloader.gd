extends Node
class_name AudioDownloader


func DownloadAudio(url) -> Array:
	var file_name = str(randi())
	var download := YtDlp.download(url) \
		.set_destination("user://audio/") \
		.set_file_name(file_name) \
		.convert_to_audio(YtDlp.Audio.MP3) \
		.start()

	assert(download.get_status() == YtDlp.Download.Status.DOWNLOADING)

	await download.download_completed
	
	var data_file_path = "user://audio/" + file_name + ".info.json"
	var file_data = FileAccess.open(data_file_path, FileAccess.READ)
	var file_info = JSON.parse_string(file_data.get_as_text())
	
	var new_file_name: String = file_info.get("title")
	new_file_name = new_file_name.replace("|", "-")
	new_file_name = new_file_name.replace("\"", "-")
	print(new_file_name)
	
	DirAccess.rename_absolute("user://audio/" + file_name + ".mp3", "user://audio/" + new_file_name + ".mp3")
	
	var new_file_path: String = "user://audio/" + new_file_name + ".mp3"
	var audio_dir = DirAccess.open("user://audio/")
	
	file_data.close()
	audio_dir.remove(file_name + ".info.json")
	
	return [new_file_path, new_file_name]