extends GutTest

var renderer: TileMapRenderer


func before_each() -> void:
	renderer = TileMapRenderer.new()
	add_child_autofree(renderer)


func test_render_creates_tile_map_layer_child() -> void:
	var layers: Array[GridLayer] = [_make_layer_with_tileset()]
	renderer.render({}, _make_config(), layers)
	assert_eq(renderer.get_child_count(), 1)


func test_render_does_not_duplicate_tile_map_layer() -> void:
	var layer: GridLayer = _make_layer_with_tileset()
	var layers: Array[GridLayer] = [layer]
	renderer.render({}, _make_config(), layers)
	renderer.render({}, _make_config(), layers)
	assert_eq(renderer.get_child_count(), 1)


func test_render_sets_z_index_on_tile_map_layer() -> void:
	var layer: GridLayer = _make_layer_with_tileset()
	layer.z_index = 5
	renderer.render({}, _make_config(), [layer])
	var tml: TileMapLayer = renderer.get_child(0)
	assert_eq(tml.z_index, 5)


func test_render_hides_invisible_layer() -> void:
	var layer: GridLayer = _make_layer_with_tileset()
	layer.visible = false
	renderer.render({}, _make_config(), [layer])
	var tml: TileMapLayer = renderer.get_child(0)
	assert_false(tml.visible)


func test_clear_hides_all_tile_map_layers() -> void:
	var layer: GridLayer = _make_layer_with_tileset()
	layer.visible = true
	renderer.render({"movement": [Vector2i(0, 0)] as Array[Vector2i]}, _make_config(), [layer])
	renderer.clear()
	var tml: TileMapLayer = renderer.get_child(0)
	assert_false(tml.visible)


func test_layer_without_tileset_does_not_create_child() -> void:
	var layer: GridLayer = GridLayer.new()
	layer.layer_name = "broken"
	layer.tile_set = null
	renderer.render({}, _make_config(), [layer])
	assert_eq(renderer.get_child_count(), 0)


func _make_layer_with_tileset(name: String = "movement") -> GridLayer:
	var l: GridLayer = GridLayer.new()
	l.layer_name = name
	l.z_index = 0
	l.visible = true
	l.tile_set = TileSet.new()
	l.tile_source_id = 0
	l.tile_atlas_coords = Vector2i(0, 0)
	return l


func _make_config() -> GridConfig:
	return GridConfig.new(GridManager.TileShape.SQUARE, Vector2(64.0, 64.0), Vector2.ZERO)
