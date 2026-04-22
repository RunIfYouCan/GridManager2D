@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type(
		"GridManager",
		"Node2D",
		preload("res://grid_manager.gd"),
		preload("res://icon.svg")
	)

func _exit_tree() -> void:
	remove_custom_type("GridManager")
