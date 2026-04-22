class_name TileMapRenderer
extends Node

var _tile_map_layers: Dictionary = {}  # String -> TileMapLayer

func render(layer_cells: Dictionary, _grid_config: GridConfig, layers: Dictionary) -> void:
	for layer_name in layers:
		var layer: GridLayer = layers[layer_name]
		if not _tile_map_layers.has(layer_name):
			_create_tile_map_layer(layer_name, layer)
		var tml: TileMapLayer = _tile_map_layers.get(layer_name)
		if tml == null:
			continue
		tml.z_index = layer.z_index
		tml.visible = layer.visible
		tml.clear()
		if not layer.visible:
			continue
		var cells: Array = layer_cells.get(layer_name, [])
		for cell in cells:
			tml.set_cell(cell, layer.tile_source_id, layer.tile_atlas_coords)

func clear() -> void:
	for tml in _tile_map_layers.values():
		tml.clear()
		tml.visible = false

func _create_tile_map_layer(layer_name: String, layer: GridLayer) -> void:
	if layer.tile_set == null:
		push_warning("TileMapRenderer: layer '%s' has no tile_set assigned." % layer_name)
		return
	var tml := TileMapLayer.new()
	tml.tile_set = layer.tile_set
	tml.z_index = layer.z_index
	add_child(tml)
	_tile_map_layers[layer_name] = tml
