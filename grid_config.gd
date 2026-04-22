class_name GridConfig

var tile_shape: int  # GridManager.TileShape value
var cell_size: Vector2
var grid_origin: Vector2

func _init(shape: int, size: Vector2, origin: Vector2) -> void:
	tile_shape = shape
	cell_size = size
	grid_origin = origin
