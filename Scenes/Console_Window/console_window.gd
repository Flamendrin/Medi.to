extends PanelContainer

signal DOWNLOAD_COMPLETE

@onready var input_bar: LineEdit = $HBoxContainer/Console_Display/InputBar
@onready var display: RichTextLabel = $HBoxContainer/Console_Display/ScrollContainer/Display

@export_multiline var welcome_msg: String = ""
@export_multiline var credits: String = ""

@export var msg_buffer_limit: int = 100


var msg_buffer: PackedStringArray = []
var msg_history := CommandHistory.new()
var command_registry = TreeStringRegistry.new()
var command_modules: Array = []
var url_ready: bool = false
var is_downloading: bool = false

func add_command_module(module: Command_Module):
	module.console = self
	command_modules.push_back(module)

	for command in module.command_refs.keys():
		command_registry.add_string(command)

func _ready() -> void:
	display_welcome_msg()
	Global.SETUP_STARTED.connect(announce_setup_start)
	Global.SETUP_FINISHED.connect(announce_setup_finished)
	var args = OS.get_cmdline_args()
	print(args)
	get_viewport().files_dropped.connect(on_files_dropped)
	set_volume(50)
	input_bar.text_submitted.connect(enter_command)
	input_bar.gui_input.connect(check_ib_input)
	input_bar.grab_focus()
	display.meta_clicked.connect(meta_clicked)
	
	close_environment_info()
	close_mp3()
	
	if args[0].ends_with(".wav") or args[0].ends_with(".mp3") or args[0].ends_with(".ogg"):
		print(args)
		on_files_dropped(args)

func announce_setup_start():
	push_msg("URL Setup Started!\n")

func announce_setup_finished():
	url_ready = true
	push_msg("URL Setup Finished. Command \"url\" is now available.\n")

func display_welcome_msg():
	push_msg(welcome_msg)

func push_msg(msg) -> void:
	msg_buffer.push_back(msg)
	if msg_buffer.size() > msg_buffer_limit:
		msg_buffer.remove_at(0)
	display.parse_bbcode("\n".join(msg_buffer))

func clear_output() -> void:
	msg_buffer = []
	display.parse_bbcode("")

func parse_input(input):
	var tokenized = input.split(" ", false, 1)
	if tokenized.size() == 0:
		return
	
	var command = tokenized[0].to_lower()
	var command_module = null
	for module in command_modules:
		if module.has_command(command):
			command_module = module
			break
	
	if command_module == null:
		push_msg("Command not found: " + command + "\nUse \"help\" to list all the available commands.")
		return
	
	var args = ""
	if tokenized.size() > 1:
		args = tokenized[1]
	
	command_module.command_entered(command, args)

func enter_command(input: String) -> void:
	input_bar.clear()
	if input.length() == 0:
		return
	
	msg_history.push(input)
	parse_input(input)

func check_ib_input(event) -> void:
	if event is InputEventKey:
		if !event.pressed:
			return
		
		if event.keycode == KEY_UP:
			input_bar.text = msg_history.next()
			input_bar.caret_column = input_bar.text.length()
		if event.keycode == KEY_DOWN:
			input_bar.text = msg_history.prev()
			input_bar.caret_column = input_bar.text.length()
		if event.keycode == KEY_TAB:
			var new_string = command_registry.get_next_divergence(input_bar.text)
			if new_string == null:
				return

			input_bar.text = new_string
			input_bar.caret_column = input_bar.text.length()

func meta_clicked(variant):
	if variant is String:
		if variant.begins_with("https://"):
			OS.shell_open(variant)
		

#####

func set_volume(volume):
	if env_window:
		Global.volume = clamp(volume, 0, 100)
		AudioServer.set_bus_volume_db(0, -35 + (Global.volume / 2.0))
		env_window.update_info()
		mp_3.update_info()

func stop():
	if env_window.is_playing:
		close_environment_info()
	if mp_3.is_playing:
		mp_3.stop()
		close_mp3()

func pause():
	if env_window.is_playing:
		pass
	if mp_3.is_playing:
		mp_3.pause()

func resume():
	if env_window.is_playing:
		pass
	if mp_3.is_playing:
		mp_3.resume()

func skip_audio():
	if mp_3.is_playing:
		mp_3.play_next()

#####

@onready var env_window: Env_Window = $HBoxContainer/Env_Window

var environment_path: String

func load_environment(env_path):
	env_window.environment = load(env_path)
	env_window.update_info()
	open_environment_info()

func open_environment_info():
	env_window.is_playing = true
	env_window.is_playing = true
	env_window.visible = true
	if mp_3.is_playing:
		pass

func close_environment_info():
	env_window.environment = null
	env_window.is_playing = false
	env_window.visible = false

func set_index_var_value(index, volume):
	if env_window:
		env_window.environment.RTPC_Variables[index].value = volume
		env_window.update_info()

######

@onready var mp_3: MP3 = $HBoxContainer/MP3

func close_mp3():
	mp_3.is_playing = false
	mp_3.visible = false

func play_audio(audio_path):
	mp_3.is_playing = true
	mp_3.play_audio(audio_path)
	mp_3.update_info()

func on_files_dropped(files):
	if FileAccess.file_exists(files[0]):
		mp_3.write_to_queue(files)
		mp_3.check_if_playing()
		mp_3.is_playing = true
		push_msg("Loaded new audio files:\n----\n\n" + "\n\n".join(files) + "\n")
	else:
		push_msg("There was a problem with your audio file.")

func download_url_audio(url):
	push_msg("Downloading Audio!")
	var new_download = AudioDownloader.new()
	var get_audio = await new_download.DownloadAudio(url)
	push_msg("Audio Downloaded!")
	return get_audio

func play_url_audio(url) -> void:
	var get_audio = await download_url_audio(url)
	while get_audio == null:
		await get_tree().create_timer(1).timeout
	print("Download_Completed")
	var file_path = get_audio[0]
	var file_name = get_audio[1]
	var D_Song: PackedStringArray = ["user://audio/" + file_name + ".mp3"]
	
	on_files_dropped(D_Song)

func store_url_audio(url):
	if Global.download_folder != "":
		pass
	else:
		push_msg("Download folder is not set. Please set your download directory via \"set_download_folder\".\n")
		return
	
	var get_audio = await download_url_audio(url)
	var file_path = get_audio[0]
	var file_name = get_audio[1]
	var audio_dir = DirAccess.rename_absolute(file_path, Global.download_folder + "/" + file_name + ".mp3")
	print(Global.download_folder + "/" + file_name + ".mp3")
	
	push_msg("Download completed - audio stored in your download folder!")

func display_credits() -> void:
	push_msg(credits)
