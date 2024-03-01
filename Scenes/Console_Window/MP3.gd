extends VBoxContainer
class_name MP3

@onready var mp_3_player_device: AudioStreamPlayer = $"../../MP3_Player_Device"

@onready var info_box: RichTextLabel = $Info
@onready var display: RichTextLabel = $Environment_Info/Display
@onready var display_ts: RichTextLabel = $TimeStamp/HBoxContainer/Display
@onready var time: RichTextLabel = $TimeStamp/HBoxContainer/Time


var audio_queue: Array = []
var temp_queue: PackedStringArray = []

var current_audio: String = ""
var playback_length

var is_playing = false

func _ready() -> void:
	mp_3_player_device.finished.connect(check_if_playing)

func _exit_tree() -> void:
	clear_cache()

func _process(_delta: float) -> void:
	if is_playing:
		var time_value
		var seconds
		var minutes
		
		time_value = int(floor(mp_3_player_device.get_playback_position()))
		seconds = time_value % 60
		time_value /= 60
		minutes = time_value % 60
		
		var time_s = "%02d:%02d" % [minutes, seconds]
		time.parse_bbcode(time_s)
		
		
		if mp_3_player_device.stream:
			var playback_1p: float = playback_length / 100
			var playback_cp: int = round(int(floor(mp_3_player_device.get_playback_position() / playback_1p))) / 5
			var playback_remaining: int = 20 - playback_cp
			
			var time_stamp_status = ""
			for i in playback_cp:
				time_stamp_status += "●"
			for i in playback_remaining:
				time_stamp_status += "-"
			
			display_ts.parse_bbcode(time_stamp_status)

func play_from_queue(file_path):
		var audio_loader = AudioLoaderV2.new()
		mp_3_player_device.set_stream(audio_loader.loadfile(file_path))
		if !mp_3_player_device.stream:
			return
		playback_length = mp_3_player_device.stream.get_length()
		mp_3_player_device.pitch_scale = 1
		visible = true
		mp_3_player_device.play()

func update_info():
	var box_info = "MP3 Player\n----\nVolume: "
	
	var display_value_bi: int = round(Global.volume / 5.0)
	var display_value_remaining_bi: int = 20 - display_value_bi
	
	for i in display_value_bi:
		box_info += "|"
	for i in display_value_remaining_bi:
		box_info += "-"
	
	var display_current_audio
	
	if current_audio.begins_with("user://audio/"):
		var current_split = current_audio.split("/")
		print(current_split)
		display_current_audio = current_split[3]
	else:
		display_current_audio = current_audio
	
	var info = "Current song:\n----\n[%s]\n\nQueue:\n----\n" % [display_current_audio]
	
	for audio in audio_queue:
		var audio_split = audio.split("/")
		print(audio_split)
		if audio.begins_with("user://audio/"):
			info += audio_split[3] + "\n\n"
		else:
			info += current_audio
	
	info_box.parse_bbcode(box_info)
	display.parse_bbcode(info)

func pause():
	mp_3_player_device.stream_paused = true

func resume():
	mp_3_player_device.stream_paused = false

func stop():
	mp_3_player_device.stop()
	current_audio = ""
	audio_queue = []
	clear_cache()
	update_info()

func write_to_queue(file_data):
		for file: String in file_data:
			audio_queue.append(file)
			update_info()
			temp_queue.append(file)

func check_if_playing():
	if !mp_3_player_device.playing:
		check_cached(current_audio)
		play_next()

func play_next():
	var new_audio = audio_queue.pop_front()
	if new_audio != null and FileAccess.file_exists(new_audio):
		current_audio = new_audio
		play_from_queue(new_audio)
		update_info()
	else:
		current_audio = ""
		update_info()
		mp_3_player_device.stop()

func check_cached(file):
	if temp_queue.find(file) != -1:
		if FileAccess.file_exists(file):
			var file_name: PackedStringArray = file.split("/")
			var Audio_Dir = DirAccess.open("user://audio/")
			if Audio_Dir.file_exists(file_name[3]):
				Audio_Dir.remove(file_name[3])

func clear_cache():
	var Audio_Dir = DirAccess.open("user://audio/")
	for file in Audio_Dir.get_files():
		Audio_Dir.remove(file)
