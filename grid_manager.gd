class_name GridManager
extends Node2D

enum Backend { CANVAS, TILEMAP }
enum TileShape { SQUARE, HEX }

@export var backend: Backend = Backend.CANVAS
@export var tile_shape: TileShape = TileShape.SQUARE
@export var cell_size: Vector2 = Vector2(64.0, 64.0)
@export var grid_origin: Vector2 = Vector2.ZERO
@export var layers: Dictionary = {}  # String -> GridLayer

var _renderer: BaseRenderer = null
var _layer_cells: Dictionary = {}  # String -> Array[Vector2i]

func _ready() -> void:
	if backend == Backend.CANVAS:
		_renderer = load("res://renderers/canvas_renderer.gd").new()
	else:
		_renderer = load("res://renderers/tilemap_renderer.gd").new()
	add_child(_renderer)

# --- Public API ---

func show_layer(layer_name: String, cells: Array[Vector2i]) -> void:
	if not layers.has(layer_name):
		push_error("GridManager: unknown layer '%s'" % layer_name)
		return
	_layer_cells[layer_name] = cells
	layers[layer_name].visible = true
	_refresh()

func hide_layer(layer_name: String) -> void:
	if not layers.has(layer_name):
		push_error("GridManager: unknown layer '%s'" % layer_name)
		return
	layers[layer_name].visible = false
	_refresh()

func clear_layer(layer_name: String) -> void:
	if not layers.has(layer_name):
		push_error("GridManager: unknown layer '%s'" % layer_name)
		return
	_layer_cells.erase(layer_name)
	layers[layer_name].visible = false
	_refresh()

func clear_all() -> void:
	_layer_cells.clear()
	for layer in layers.values():
		layer.visible = false
	_refresh()

func world_to_cell(world_pos: Vector2) -> Vector2i:
	if tile_shape == TileShape.SQUARE:
		return _world_to_cell_square(world_pos)
	return _world_to_cell_hex(world_pos)

func cell_to_world(cell: Vector2i) -> Vector2:
	if tile_shape == TileShape.SQUARE:
		return _cell_to_world_square(cell)
	return _cell_to_world_hex(cell)

# --- Private ---

func _refresh() -> void:
	if _renderer:
		_renderer.render(_layer_cells, _make_config(), layers)

func _make_config() -> GridConfig:
	return GridConfig.new(tile_shape, cell_size, grid_origin)

func _world_to_cell_square(world_pos: Vector2) -> Vector2i:
	var local := world_pos - grid_origin
	return Vector2i(int(floor(local.x / cell_size.x)), int(floor(local.y / cell_size.y)))

func _cell_to_world_square(cell: Vector2i) -> Vector2:
	return grid_origin + Vector2(
		cell.x * cell_size.x + cell_size.x * 0.5,
		cell.y * cell_size.y + cell_size.y * 0.5
	)

func _world_to_cell_hex(world_pos: Vector2) -> Vector2i:
	# Pointy-top hex, odd-row offset
	# Inverse of: y = grid_origin.y + row * cell_size.y * 0.75 + cell_size.y * 0.5
	var row := int(round((world_pos.y - grid_origin.y - cell_size.y * 0.5) / (cell_size.y * 0.75)))
	# Inverse of: x = grid_origin.x + col * cell_size.x + (row % 2) * cell_size.x * 0.5 + cell_size.x * 0.5
	var col := int(round((world_pos.x - grid_origin.x - (row % 2) * cell_size.x * 0.5 - cell_size.x * 0.5) / cell_size.x))
	return Vector2i(col, row)

func _cell_to_world_hex(cell: Vector2i) -> Vector2:
	# Pointy-top hex, odd-row offset
	var x := grid_origin.x + cell.x * cell_size.x + (cell.y % 2) * cell_size.x * 0.5 + cell_size.x * 0.5
	var y := grid_origin.y + cell.y * cell_size.y * 0.75 + cell_size.y * 0.5
	return Vector2(x, y)

func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if cell_size == Vector2.ZERO:
		warnings.append("cell_size must not be zero.")
	if backend == Backend.TILEMAP:
		for layer_name in layers:
			var layer: GridLayer = layers[layer_name]
			if layer.tile_set == null:
				warnings.append("Layer '%s': tile_set is required for TileMap backend." % layer_name)
	return warnings
