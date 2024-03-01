extends Node

func _ready() -> void:
	get_parent().add_command_module($Console)
	get_parent().add_command_module($Audio)
	#get_parent().add_command_module($Environment)
	#get_parent().add_command_module($MP3)

func on_command_cls(console, _args):
	console.clear_output()

func on_command_echo(console, args):
	console.push_msg(args[0])

func on_command_help(console, _args):
	var msg = "/////////////---Help---/////////////////////////////////////\n\n"
	msg += "Console: \n"
	msg += "   Commands are used as follows: [command <arg1> <arg2> ...]\n"
	msg += "   Arguments with spaces in between words can be enclosed with quotation marks.\n\n"
	msg += "Media Player: \n"
	msg += "   You can play \".wav\", \".mp3\" and \".ogg\" files by droping them onto this window.\n\n"

	msg += "/////////////////////////////\n\n"
	msg += "Available modules:\n\n"
	
	for module in console.command_modules:
		msg += module.generate_help_string()
	
	console.push_msg(msg)

func on_command_wlcm(console, _args):
	console.display_welcome_msg()

func on_command_credits(console, _args):
	console.display_credits()


###################

func on_command_env(console, args):
	var valid_env = false
	var env_path: String
	match args[0]:
		"forest":
			env_path = "res://Environments/Forest/forest.tres"
			valid_env = true
		"space":
			valid_env = true
		"campfire":
			valid_env = true
	
	if valid_env:
		console.load_environment(env_path)
		console.push_msg("Entered envrionment: " + args[0] +"\n")
	else:
		var msg = "Invalid environment. These are valid options: \n"
		msg += "	- forest\n"
		msg += "	- space\n"
		msg += "	- campfire\n\n"
		console.push_msg(msg)

func on_command_stop(console, _args):
	console.stop()
	console.push_msg("Audio stoped!\n")

func on_command_pause(console, _args):
	console.pause()
	console.push_msg("Audio paused.\n")

func on_command_resume(console, _args):
	console.resume()
	console.push_msg("Audio resumed.\n")

func on_command_volume(console, args):
	console.set_volume(args[0])

func on_command_v(console, args):
	console.set_volume(args[0])

func on_command_set(console, args):
	console.set_index_var_value(args[0], args[1])

func on_command_play(console, args):
	
	var audio_path: String
	var valid_audio = false
	
	match args[0]:
		"Resolve":
			valid_audio = true
			audio_path = "res://MP3/Songs/Resolve.tres"
	
	if valid_audio:
		console.play_audio(audio_path)
	else:
		var _msg = "Invalid song name. Please use \"list\" to display all your audio files."

func on_command_skip(console, _args):
	console.skip_audio()

func on_command_url(console, args):
	console.play_url_audio(args[0])

func on_command_set_download_folder(console, args):
	var download_folder_path: String = args[0]
	if download_folder_path.ends_with("/"):
		download_folder_path.erase(download_folder_path.length() - 1, 1)
	
	Global.download_folder = download_folder_path
	console.push_msg("Download directory is set to \"%s\"\n" % args[0])

func on_command_download(console, args):
	console.store_url_audio(args[0])
