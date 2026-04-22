@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"GridManager",
		"Node2D",
		preload("./grid_manager.gd"),
		null
	)
	add_custom_type(
		"GridLayer",
		"Resource",
		preload("./grid_layer.gd"),
		null
	)

func _exit_tree() -> void:
	remove_custom_type("GridManager")
	remove_custom_type("GridLayer")
