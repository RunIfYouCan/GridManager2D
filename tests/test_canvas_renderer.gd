extends GutTest

var renderer: CanvasRenderer


func before_each() -> void:
	renderer = CanvasRenderer.new()
	add_child_autofree(renderer)


func test_render_stores_data() -> void:
	var layer: GridLayer = _make_layer(0, "movement")
	var cells: Array[Vector2i] = [Vector2i(0, 0)]
	var layer_cells: Dictionary = {"movement": cells}
	var layers: Array[GridLayer] = [layer]
	renderer.render(layer_cells, _make_config(), layers)
	assert_eq(renderer.layer_cells, layer_cells)
	assert_eq(renderer.layers, layers)


func test_clear_empties_layer_cells() -> void:
	var layers: Array[GridLayer] = [_make_layer(0, "movement")]
	renderer.render({"movement": [Vector2i(0, 0)] as Array[Vector2i]}, _make_config(), layers)
	renderer.clear()
	assert_eq(renderer.layer_cells.size(), 0)


func test_clear_empties_layers() -> void:
	var layers: Array[GridLayer] = [_make_layer(0, "movement")]
	renderer.render({"movement": [Vector2i(0, 0)] as Array[Vector2i]}, _make_config(), layers)
	renderer.clear()
	assert_eq(renderer.layers.size(), 0)


func test_hex_polygon_returns_six_points() -> void:
	var center: Vector2 = Vector2(32.0, 32.0)
	var cell_size: Vector2 = Vector2(64.0, 64.0)
	var points: PackedVector2Array = renderer.hex_polygon(center, cell_size)
	assert_eq(points.size(), 6)


func test_square_cell_center() -> void:
	var cfg: GridConfig = _make_config(GridManager.TileShape.SQUARE)
	var center: Vector2 = renderer.cell_center(Vector2i(0, 0), cfg)
	assert_eq(center, Vector2(32.0, 32.0))


func test_square_cell_center_non_origin() -> void:
	var cfg: GridConfig = _make_config(GridManager.TileShape.SQUARE)
	var center: Vector2 = renderer.cell_center(Vector2i(2, 1), cfg)
	assert_eq(center, Vector2(160.0, 96.0))


func test_hex_cell_center_even_row() -> void:
	var cfg: GridConfig = _make_config(GridManager.TileShape.HEX)
	var center: Vector2 = renderer.cell_center(Vector2i(0, 0), cfg)
	assert_eq(center, Vector2(32.0, 32.0))


func _make_config(shape: GridManager.TileShape = GridManager.TileShape.SQUARE) -> GridConfig:
	return GridConfig.new(shape, Vector2(64.0, 64.0), Vector2.ZERO)


func _make_layer(z: int = 0, name: String = "layer") -> GridLayer:
	var l: GridLayer = GridLayer.new()
	l.layer_name = name
	l.z_index = z
	l.visible = true
	l.fill_color = Color(0.2, 0.6, 1.0, 0.4)
	l.border_color = Color.WHITE
	l.border_width = 2.0
	return l
