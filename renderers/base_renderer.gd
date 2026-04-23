@abstract
class_name BaseRenderer
extends Node2D


@abstract func render(
	_layer_cells: Dictionary, _grid_config: GridConfig, _layers: Array[GridLayer]
) -> void


@abstract func clear() -> void
