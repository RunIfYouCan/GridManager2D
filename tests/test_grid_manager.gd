extends GutTest

var gm: GridManager


func before_each() -> void:
	gm = GridManager.new()
	gm.tile_shape = GridManager.TileShape.SQUARE
	gm.cell_size = Vector2(64.0, 64.0)
	gm.grid_origin = Vector2.ZERO


func after_each() -> void:
	gm.free()

# --- Square coordinate math ---


func test_cell_to_world_square_origin_cell() -> void:
	assert_eq(gm.cell_to_world(Vector2i(0, 0)), Vector2(32.0, 32.0))


func test_cell_to_world_square_non_origin() -> void:
	assert_eq(gm.cell_to_world(Vector2i(2, 3)), Vector2(160.0, 224.0))


func test_cell_to_world_square_with_grid_origin_offset() -> void:
	gm.grid_origin = Vector2(100.0, 50.0)
	assert_eq(gm.cell_to_world(Vector2i(0, 0)), Vector2(132.0, 82.0))


func test_world_to_cell_square_center_of_first_cell() -> void:
	assert_eq(gm.world_to_cell(Vector2(32.0, 32.0)), Vector2i(0, 0))


func test_world_to_cell_square_top_left_of_cell() -> void:
	assert_eq(gm.world_to_cell(Vector2(0.0, 0.0)), Vector2i(0, 0))


func test_world_to_cell_square_second_cell() -> void:
	assert_eq(gm.world_to_cell(Vector2(96.0, 64.0)), Vector2i(1, 1))

# --- Hex coordinate math ---


func test_cell_to_world_hex_origin_even_row() -> void:
	gm.tile_shape = GridManager.TileShape.HEX
	assert_eq(gm.cell_to_world(Vector2i(0, 0)), Vector2(32.0, 32.0))


func test_cell_to_world_hex_odd_row_offset() -> void:
	gm.tile_shape = GridManager.TileShape.HEX
	assert_eq(gm.cell_to_world(Vector2i(0, 1)), Vector2(64.0, 80.0))


func test_world_to_cell_hex_round_trips() -> void:
	gm.tile_shape = GridManager.TileShape.HEX
	var original: Vector2i = Vector2i(3, 2)
	var world: Vector2 = gm.cell_to_world(original)
	assert_eq(gm.world_to_cell(world), original)

# --- Layer API ---


func test_show_layer_stores_cells() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	var cells: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
	mgr.show_layer("movement", cells)
	assert_eq(mgr.layer_cells["movement"], cells)


func test_show_layer_sets_layer_visible() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	assert_true(mgr.find_layer("movement").visible)


func test_hide_layer_sets_invisible() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.hide_layer("movement")
	assert_false(mgr.find_layer("movement").visible)


func test_hide_layer_preserves_cell_data() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	var cells: Array[Vector2i] = [Vector2i(2, 3)]
	mgr.show_layer("movement", cells)
	mgr.hide_layer("movement")
	assert_eq(mgr.layer_cells["movement"], cells)


func test_clear_layer_removes_cells() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_layer("movement")
	assert_false(mgr.layer_cells.has("movement"))


func test_clear_layer_sets_invisible() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_layer("movement")
	assert_false(mgr.find_layer("movement").visible)


func test_clear_all_removes_all_cells() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_all()
	assert_eq(mgr.layer_cells.size(), 0)


func test_clear_all_sets_all_layers_invisible() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_all()
	assert_false(mgr.find_layer("movement").visible)


func test_unknown_layer_does_not_crash_show() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.show_layer("nonexistent", [Vector2i(0, 0)])
	assert_true(true)


func test_unknown_layer_does_not_crash_hide() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.hide_layer("nonexistent")
	assert_true(true)


func test_unknown_layer_does_not_crash_clear() -> void:
	var mgr: GridManager = _make_gm_with_layer()
	mgr.clear_layer("nonexistent")
	assert_true(true)

# --- Validation ---


func test_no_warnings_when_configured_correctly() -> void:
	gm.cell_size = Vector2(64.0, 64.0)
	gm.backend = GridManager.Backend.CANVAS
	assert_eq(gm.get_warnings().size(), 0)


func test_warns_when_cell_size_is_zero() -> void:
	gm.cell_size = Vector2.ZERO
	var warnings: PackedStringArray = gm.get_warnings()
	assert_gt(warnings.size(), 0)
	assert_true(warnings[0].contains("cell_size"))


func test_warns_when_tilemap_layer_missing_tileset() -> void:
	gm.backend = GridManager.Backend.TILEMAP
	var layer: GridLayer = GridLayer.new()
	layer.layer_name = "attack"
	layer.tile_set = null
	var layers: Array[GridLayer] = [layer]
	gm.layers = layers
	var warnings: PackedStringArray = gm.get_warnings()
	assert_gt(warnings.size(), 0)
	assert_true(warnings[0].contains("attack"))


func test_no_tileset_warning_for_canvas_backend() -> void:
	gm.backend = GridManager.Backend.CANVAS
	var layer: GridLayer = GridLayer.new()
	layer.layer_name = "attack"
	layer.tile_set = null
	var layers: Array[GridLayer] = [layer]
	gm.layers = layers
	assert_eq(gm.get_warnings().size(), 0)


func _make_gm_with_layer() -> GridManager:
	var mgr: GridManager = GridManager.new()
	mgr.tile_shape = GridManager.TileShape.SQUARE
	mgr.cell_size = Vector2(64.0, 64.0)
	mgr.grid_origin = Vector2.ZERO
	var layer: GridLayer = GridLayer.new()
	layer.layer_name = "movement"
	layer.fill_color = Color.BLUE
	layer.z_index = 0
	layer.visible = false
	mgr.layers = [layer]
	add_child_autofree(mgr)
	return mgr
