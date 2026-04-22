class_name GridLayer
extends Resource

@export var layer_name: String = ""

# Shared
@export var z_index: int = 0
@export var visible: bool = true

# Canvas backend
@export var fill_color: Color = Color(0.2, 0.6, 1.0, 0.4)
@export var border_color: Color = Color(1.0, 1.0, 1.0, 0.8)
@export var border_width: float = 2.0

# TileMap backend
@export var tile_set: TileSet = null
@export var tile_source_id: int = 0
@export var tile_atlas_coords: Vector2i = Vector2i(0, 0)
