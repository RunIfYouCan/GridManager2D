class_name CanvasRenderer
extends Node2D

var _layer_cells: Dictionary = {}   # String -> Array[Vector2i]
var _grid_config: GridConfig = null
var _layers: Array[GridLayer] = []

func render(layer_cells: Dictionary, grid_config: GridConfig, layers: Array[GridLayer]) -> void:
	_layer_cells = layer_cells
	_grid_config = grid_config
	_layers = layers
	queue_redraw()

func clear() -> void:
	_layer_cells = {}
	_layers = []
	_grid_config = null
	queue_redraw()

func _draw() -> void:
	if _grid_config == null:
		return

	var sorted_layers := _layers.duplicate()
	sorted_layers.sort_custom(func(a: GridLayer, b: GridLayer) -> bool:
		return a.z_index < b.z_index
	)

	for layer: GridLayer in sorted_layers:
		if not layer.visible:
			continue
		var cells: Array = _layer_cells.get(layer.layer_name, [])
		for cell in cells:
			_draw_cell(cell, layer)

func _draw_cell(cell: Vector2i, layer: GridLayer) -> void:
	var center := _cell_center(cell, _grid_config)
	if _grid_config.tile_shape == GridManager.TileShape.SQUARE:
		var rect := Rect2(center - _grid_config.cell_size * 0.5, _grid_config.cell_size)
		draw_rect(rect, layer.fill_color)
		if layer.border_width > 0.0:
			draw_rect(rect, layer.border_color, false, layer.border_width)
	else:
		var polygon := _hex_polygon(center, _grid_config.cell_size)
		draw_colored_polygon(polygon, layer.fill_color)
		if layer.border_width > 0.0:
			var closed := PackedVector2Array(polygon)
			closed.append(polygon[0])
			draw_polyline(closed, layer.border_color, layer.border_width)

func _cell_center(cell: Vector2i, cfg: GridConfig) -> Vector2:
	if cfg.tile_shape == GridManager.TileShape.SQUARE:
		return cfg.grid_origin + Vector2(
			cell.x * cfg.cell_size.x + cfg.cell_size.x * 0.5,
			cell.y * cfg.cell_size.y + cfg.cell_size.y * 0.5
		)
	# Pointy-top hex, odd-row offset
	var x := cfg.grid_origin.x + cell.x * cfg.cell_size.x \
		+ posmod(cell.y, 2) * cfg.cell_size.x * 0.5 + cfg.cell_size.x * 0.5
	var y := cfg.grid_origin.y + cell.y * cfg.cell_size.y * 0.75 + cfg.cell_size.y * 0.5
	return Vector2(x, y)

func _hex_polygon(center: Vector2, cell_size: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	var rx := cell_size.x * 0.5
	var ry := cell_size.y * 0.5
	for i in range(6):
		var angle := deg_to_rad(60.0 * i - 30.0)  # pointy-top: first point at top
		points.append(center + Vector2(rx * cos(angle), ry * sin(angle)))
	return points
