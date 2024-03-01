extends Node

signal SETUP_STARTED
signal SETUP_FINISHED

####
var volume: int = 50

var download_folder: String = ""

####
func _ready() -> void:
	await get_tree().create_timer(0.3).timeout
	var username
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	else:
		username = "Player"
	download_folder = "C:/Users/%s/Downloads" % username
	print(download_folder)
	print("Setup started!")
	emit_signal("SETUP_STARTED")
	if not YtDlp.is_setup():
		YtDlp.setup()
		await YtDlp.setup_completed
		print("Setup completed!")
		emit_signal("SETUP_FINISHED")
