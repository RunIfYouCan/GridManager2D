extends GutTest

const CanvasRendererScript = preload("res://renderers/canvas_renderer.gd")
const GridConfigScript = preload("res://grid_config.gd")
const GridLayerScript = preload("res://grid_layer.gd")
const GridManagerScript = preload("res://grid_manager.gd")

var renderer

func before_each() -> void:
	renderer = CanvasRendererScript.new()
	add_child_autofree(renderer)

func _make_config(shape := GridManagerScript.TileShape.SQUARE) -> GridConfigScript:
	return GridConfigScript.new(shape, Vector2(64.0, 64.0), Vector2.ZERO)

func _make_layer(z: int = 0) -> GridLayerScript:
	var l := GridLayerScript.new()
	l.z_index = z
	l.visible = true
	l.fill_color = Color(0.2, 0.6, 1.0, 0.4)
	l.border_color = Color.WHITE
	l.border_width = 2.0
	return l

func test_render_stores_data() -> void:
	var cells: Array[Vector2i] = [Vector2i(0, 0)]
	var layer_cells := {"movement": cells}
	var layer_dict := {"movement": _make_layer()}
	renderer.render(layer_cells, _make_config(), layer_dict)
	assert_eq(renderer._layer_cells, layer_cells)
	assert_eq(renderer._layers, layer_dict)

func test_clear_empties_layer_cells() -> void:
	var layer_cells := {"movement": [Vector2i(0, 0)] as Array[Vector2i]}
	renderer.render(layer_cells, _make_config(), {"movement": _make_layer()})
	renderer.clear()
	assert_eq(renderer._layer_cells.size(), 0)

func test_clear_empties_layers() -> void:
	renderer.render({"movement": [Vector2i(0, 0)] as Array[Vector2i]}, _make_config(), {"movement": _make_layer()})
	renderer.clear()
	assert_eq(renderer._layers.size(), 0)

func test_hex_polygon_returns_six_points() -> void:
	var center := Vector2(32.0, 32.0)
	var cell_size := Vector2(64.0, 64.0)
	var points: PackedVector2Array = renderer._hex_polygon(center, cell_size)
	assert_eq(points.size(), 6)

func test_square_cell_center() -> void:
	var cfg := _make_config(GridManagerScript.TileShape.SQUARE)
	var center: Vector2 = renderer._cell_center(Vector2i(0, 0), cfg)
	assert_eq(center, Vector2(32.0, 32.0))

func test_square_cell_center_non_origin() -> void:
	var cfg := _make_config(GridManagerScript.TileShape.SQUARE)
	var center: Vector2 = renderer._cell_center(Vector2i(2, 1), cfg)
	assert_eq(center, Vector2(160.0, 96.0))

func test_hex_cell_center_even_row() -> void:
	var cfg := _make_config(GridManagerScript.TileShape.HEX)
	var center: Vector2 = renderer._cell_center(Vector2i(0, 0), cfg)
	assert_eq(center, Vector2(32.0, 32.0))
