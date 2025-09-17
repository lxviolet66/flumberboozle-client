extends Node


func find_node(pattern: String) -> Node:
	return get_tree().get_root().find_child(pattern, true, false)
