extends Node
class_name TrieNode

var children: Dictionary = {}
var data = null
var terminal = false

func add_node(key, node):
    assert(!children.has(key), "Can't add key, it already exists")
    children[key] = node