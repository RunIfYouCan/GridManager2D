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
