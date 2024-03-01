@icon("res://Assets/Icons/CMD_G.png")
extends Node
class_name Command_Group

func _ready() -> void:
	assert(name.find(" ") == -1)
	name = name.to_lower()
