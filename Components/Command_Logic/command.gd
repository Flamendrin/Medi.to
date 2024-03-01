@icon("res://Assets/Icons/CMD.png")
extends Node
class_name Command

enum ArgumentType {
	FLOAT,
	INT,
	STRING,
}

@export var argument_names: Array[String] = []
@export var argument_types: Array[ArgumentType] = []

@export_multiline var help: String = ""

var callback: String:
	set = callback_set,
	get = callback_get

func callback_set(string):
	callback = "on_command_" + string
func callback_get():
	return callback

func _ready() -> void:
	assert(argument_types.size() == argument_names.size())
	assert(name.find(" ") == -1) # No spaces
	name = name.to_lower()

func parse_arguments(args: String):
	var arg_array = []
	var segmented = args.split(" ", false)
	var grouped: PackedStringArray = []
	
	var quoted = false
	for segment in segmented:
		if segment.begins_with("\""):
			quoted = true
			segment = segment.erase(0, 1)
		if segment.ends_with("\""):
			quoted = false
			segment = segment.erase(segment.length() - 1, 1)
			grouped.push_back(segment)
			segment = " ".join(grouped)
			grouped = []
		
		if quoted:
			grouped.push_back(segment)
		else:
			arg_array.push_back(segment)
	
	if grouped.size() != 0:
		return "Invalid argument format (Incomplete qoute): " + " ".join(grouped)
	
	if arg_array.size() != argument_types.size():
		return "Invalid number of arguments (Expected: %s, Recieved: %s)" % [
			str(argument_types.size()),
			str(arg_array.size())
		]
	
	for i in range(argument_types.size()):
		match(argument_types[i]):
			ArgumentType.FLOAT:
				arg_array[i] = float(arg_array[i])
			ArgumentType.INT:
				arg_array[i] = int(arg_array[i])
	
	return arg_array

func get_usage():
	var usage: String = "Usage: %s " % name
	
	for i in range(argument_types.size()):
		var arg_type = ArgumentType.keys()[argument_types[i]]
		var arg_name = argument_names[i]
		arg_type = arg_type.to_lower()
		arg_name = arg_name.to_lower()
		
		usage += "<%s:%s> " % [arg_name, arg_type]
		
		return usage

func get_namespace_to(target: Node):
	var namespc: PackedStringArray
	var node = self
	while node != target:
		namespc.insert(0, node.name)
		node = node.get_parent()
	
	return namespc
