extends Node
class_name TreeStringRegistry

var root_node = TrieNode.new()

func _init():
	root_node.data = ""

func add_string(string):
	var node = root_node
	var prev_node = node
	for i in range(string.length()):
		var c = string[i]
		prev_node = node
		node = node.children.get(c)
		if node == null:
			node = TrieNode.new()
			node.data = string.substr(0, i + 1)
			prev_node.add_node(c, node)
	
	if node != root_node:
		node.terminal = true

func get_next_divergence(string):
	var node = _get_node_at(string)
	if node == null:
		return null
	
	while (node.children.size() == 1 or !node.terminal):
		node = node.children.values()[0]
		assert(node != null, "Null value on Tree Node child array...")
	
	return node.data

func _get_node_at(string):
	var node = root_node
	for i in range(string.length()):
		node = node.children.get(string[i])
		if node == null:
			break
		
		return node
