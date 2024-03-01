extends VBoxContainer
class_name Env_Window

@onready var info_box: RichTextLabel = $Info
@onready var display: RichTextLabel = $Environment_Info/Display

@export var environment: Medito_Environment

var is_playing = false

func _ready() -> void:
	pass

func update_info():
	if !environment:
		return
	
	var box_info = "Environment: %s\n" % environment.Environment_Name
	box_info += "----\n"
	box_info += "Volume: "
	
	###ADD TIMER###
	
	var display_value_bi: int = round(Global.volume / 5)
	var display_value_remaining_bi: int = 20 - display_value_bi
	
	for i in display_value_bi:
		box_info += "|"
	for i in display_value_remaining_bi:
		box_info += "-"
	
	var info = "Environment Settings\n----\n\n\n"
	
	var index_counter: int = 0
	
	for variable: RTPC_Variable in environment.RTPC_Variables:
		info += "%s [%s]:\n\n" % [variable.Variable_Name, index_counter]
		
		index_counter += 1
		
		var display_value: int = round(variable.value / 5)
		var display_value_remaining: int = 20 - display_value
		
		for i in display_value:
			info += "|"
		for i in display_value_remaining:
			info += "-"
		
		info += "\n\n"
	
	info_box.parse_bbcode(box_info)
	display.parse_bbcode(info)
