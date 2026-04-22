extends GutTest

const GridManagerScript = preload("res://grid_manager.gd")
const GridLayerScript = preload("res://grid_layer.gd")

var gm

func before_each() -> void:
	gm = GridManagerScript.new()
	gm.tile_shape = GridManagerScript.TileShape.SQUARE
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
	gm.tile_shape = GridManagerScript.TileShape.HEX
	# Even row: no offset. Center of cell(0,0) = origin + half cell
	assert_eq(gm.cell_to_world(Vector2i(0, 0)), Vector2(32.0, 32.0))

func test_cell_to_world_hex_odd_row_offset() -> void:
	gm.tile_shape = GridManagerScript.TileShape.HEX
	# Odd row 1: x offset by cell_size.x * 0.5 = 32
	# y: row * cell_size.y * 0.75 + cell_size.y * 0.5 = 1 * 48 + 32 = 80
	# x: col * cell_size.x + row_offset + cell_size.x * 0.5 = 0 + 32 + 32 = 64
	assert_eq(gm.cell_to_world(Vector2i(0, 1)), Vector2(64.0, 80.0))

func test_world_to_cell_hex_round_trips() -> void:
	gm.tile_shape = GridManagerScript.TileShape.HEX
	var original = Vector2i(3, 2)
	var world = gm.cell_to_world(original)
	assert_eq(gm.world_to_cell(world), original)

# --- Layer API ---
# These tests need _ready() to run so the renderer is created.

func _make_gm_with_layer() -> GridManagerScript:
	var mgr = GridManagerScript.new()
	mgr.tile_shape = GridManagerScript.TileShape.SQUARE
	mgr.cell_size = Vector2(64.0, 64.0)
	mgr.grid_origin = Vector2.ZERO
	var layer = GridLayerScript.new()
	layer.fill_color = Color.BLUE
	layer.z_index = 0
	layer.visible = false
	mgr.layers = {"movement": layer}
	add_child_autofree(mgr)
	return mgr

func test_show_layer_stores_cells() -> void:
	var mgr = _make_gm_with_layer()
	var cells: Array[Vector2i] = [Vector2i(0, 0), Vector2i(1, 0)]
	mgr.show_layer("movement", cells)
	assert_eq(mgr._layer_cells["movement"], cells)

func test_show_layer_sets_layer_visible() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	assert_true(mgr.layers["movement"].visible)

func test_hide_layer_sets_invisible() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.hide_layer("movement")
	assert_false(mgr.layers["movement"].visible)

func test_hide_layer_preserves_cell_data() -> void:
	var mgr = _make_gm_with_layer()
	var cells: Array[Vector2i] = [Vector2i(2, 3)]
	mgr.show_layer("movement", cells)
	mgr.hide_layer("movement")
	assert_eq(mgr._layer_cells["movement"], cells)

func test_clear_layer_removes_cells() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_layer("movement")
	assert_false(mgr._layer_cells.has("movement"))

func test_clear_layer_sets_invisible() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_layer("movement")
	assert_false(mgr.layers["movement"].visible)

func test_clear_all_removes_all_cells() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_all()
	assert_eq(mgr._layer_cells.size(), 0)

func test_clear_all_sets_all_layers_invisible() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("movement", [Vector2i(0, 0)])
	mgr.clear_all()
	assert_false(mgr.layers["movement"].visible)

func test_unknown_layer_does_not_crash_show() -> void:
	var mgr = _make_gm_with_layer()
	mgr.show_layer("nonexistent", [Vector2i(0, 0)])
	assert_true(true)  # passes if no crash

func test_unknown_layer_does_not_crash_hide() -> void:
	var mgr = _make_gm_with_layer()
	mgr.hide_layer("nonexistent")
	assert_true(true)

func test_unknown_layer_does_not_crash_clear() -> void:
	var mgr = _make_gm_with_layer()
	mgr.clear_layer("nonexistent")
	assert_true(true)
