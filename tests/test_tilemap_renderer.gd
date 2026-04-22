extends GutTest

const TileMapRendererScript = preload("res://renderers/tilemap_renderer.gd")
const GridConfigScript = preload("res://grid_config.gd")
const GridLayerScript = preload("res://grid_layer.gd")
const GridManagerScript = preload("res://grid_manager.gd")

var renderer

func before_each() -> void:
	renderer = TileMapRendererScript.new()
	add_child_autofree(renderer)

func _make_layer_with_tileset() -> GridLayerScript:
	var l := GridLayerScript.new()
	l.z_index = 0
	l.visible = true
	l.tile_set = TileSet.new()
	l.tile_source_id = 0
	l.tile_atlas_coords = Vector2i(0, 0)
	return l

func _make_config() -> GridConfigScript:
	return GridConfigScript.new(
		GridManagerScript.TileShape.SQUARE,
		Vector2(64.0, 64.0),
		Vector2.ZERO
	)

func test_render_creates_tile_map_layer_child() -> void:
	var layer := _make_layer_with_tileset()
	renderer.render({}, _make_config(), {"movement": layer})
	assert_eq(renderer.get_child_count(), 1)

func test_render_does_not_duplicate_tile_map_layer() -> void:
	var layer := _make_layer_with_tileset()
	renderer.render({}, _make_config(), {"movement": layer})
	renderer.render({}, _make_config(), {"movement": layer})
	assert_eq(renderer.get_child_count(), 1)

func test_render_sets_z_index_on_tile_map_layer() -> void:
	var layer := _make_layer_with_tileset()
	layer.z_index = 5
	renderer.render({}, _make_config(), {"movement": layer})
	var tml: TileMapLayer = renderer.get_child(0)
	assert_eq(tml.z_index, 5)

func test_render_hides_invisible_layer() -> void:
	var layer := _make_layer_with_tileset()
	layer.visible = false
	renderer.render({}, _make_config(), {"movement": layer})
	var tml: TileMapLayer = renderer.get_child(0)
	assert_false(tml.visible)

func test_clear_hides_all_tile_map_layers() -> void:
	var layer := _make_layer_with_tileset()
	layer.visible = true
	renderer.render({"movement": [Vector2i(0, 0)] as Array[Vector2i]}, _make_config(), {"movement": layer})
	renderer.clear()
	var tml: TileMapLayer = renderer.get_child(0)
	assert_false(tml.visible)

func test_layer_without_tileset_does_not_create_child() -> void:
	var layer := GridLayerScript.new()
	layer.tile_set = null
	renderer.render({}, _make_config(), {"broken": layer})
	assert_eq(renderer.get_child_count(), 0)
