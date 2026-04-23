class_name GridManager
extends Node2D

enum Backend { CANVAS, TILEMAP }
enum TileShape { SQUARE, HEX }

const CANVAS_RENDERER_SCRIPT = preload("./renderers/canvas_renderer.gd")
const TILEMAP_RENDERER_SCRIPT = preload("./renderers/tilemap_renderer.gd")

@export var backend: Backend = Backend.CANVAS
@export var tile_shape: TileShape = TileShape.SQUARE
@export var cell_size: Vector2 = Vector2(64.0, 64.0)
@export var grid_origin: Vector2 = Vector2.ZERO
@export var layers: Array[GridLayer] = []

var layer_cells: Dictionary = {}  # String -> Array[Vector2i]
var _renderer: BaseRenderer = null


func _ready() -> void:
	if backend == Backend.CANVAS:
		_renderer = CANVAS_RENDERER_SCRIPT.new()
	else:
		_renderer = TILEMAP_RENDERER_SCRIPT.new()
	add_child(_renderer)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = PackedStringArray()
	if cell_size == Vector2.ZERO:
		warnings.append("cell_size must not be zero.")
	for layer in layers:
		if layer.layer_name.is_empty():
			warnings.append("A layer has an empty layer_name.")
		if backend == Backend.TILEMAP and layer.tile_set == null:
			warnings.append(
				"Layer '%s': tile_set is required for TileMap backend." % layer.layer_name
			)
	return warnings


# --- Public API ---


func get_warnings() -> PackedStringArray:
	return _get_configuration_warnings()


func show_layer(layer_name: String, cells: Array[Vector2i]) -> void:
	var layer: GridLayer = find_layer(layer_name)
	if layer == null:
		push_warning("GridManager: unknown layer '%s'" % layer_name)
		return
	layer_cells[layer_name] = cells
	layer.visible = true
	_refresh()


func hide_layer(layer_name: String) -> void:
	var layer: GridLayer = find_layer(layer_name)
	if layer == null:
		push_warning("GridManager: unknown layer '%s'" % layer_name)
		return
	layer.visible = false
	_refresh()


func clear_layer(layer_name: String) -> void:
	var layer: GridLayer = find_layer(layer_name)
	if layer == null:
		push_warning("GridManager: unknown layer '%s'" % layer_name)
		return
	layer_cells.erase(layer_name)
	layer.visible = false
	_refresh()


func clear_all() -> void:
	layer_cells.clear()
	for layer in layers:
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


func find_layer(layer_name: String) -> GridLayer:
	for layer in layers:
		if layer.layer_name == layer_name:
			return layer
	return null


func _refresh() -> void:
	if _renderer:
		_renderer.render(layer_cells, _make_config(), layers)


func _make_config() -> GridConfig:
	return GridConfig.new(tile_shape, cell_size, grid_origin)


func _world_to_cell_square(world_pos: Vector2) -> Vector2i:
	var local: Vector2 = world_pos - grid_origin
	return Vector2i(int(floor(local.x / cell_size.x)), int(floor(local.y / cell_size.y)))


func _cell_to_world_square(cell: Vector2i) -> Vector2:
	return grid_origin + Vector2(
		cell.x * cell_size.x + cell_size.x * 0.5,
		cell.y * cell_size.y + cell_size.y * 0.5,
	)


func _world_to_cell_hex(world_pos: Vector2) -> Vector2i:
	# Pointy-top hex, odd-row offset
	# Inverse of: y = grid_origin.y + row * cell_size.y * 0.75 + cell_size.y * 0.5
	var row: int = int(
		round((world_pos.y - grid_origin.y - cell_size.y * 0.5) / (cell_size.y * 0.75))
	)
	# Inverse of: x = grid_origin.x + col * cell_size.x + (row%2)*cell_size.x*0.5 + cell_size.x*0.5
	var offset: float = posmod(row, 2) * cell_size.x * 0.5
	var col: int = int(
		round((world_pos.x - grid_origin.x - offset - cell_size.x * 0.5) / cell_size.x)
	)
	return Vector2i(col, row)


func _cell_to_world_hex(cell: Vector2i) -> Vector2:
	# Pointy-top hex, odd-row offset
	var x: float = (
		grid_origin.x + cell.x * cell_size.x + posmod(cell.y, 2) * cell_size.x * 0.5
		+ cell_size.x * 0.5
	)
	var y: float = grid_origin.y + cell.y * cell_size.y * 0.75 + cell_size.y * 0.5
	return Vector2(x, y)
