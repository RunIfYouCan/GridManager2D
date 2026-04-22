class_name BaseRenderer
extends Node

## Abstract base class. All renderers must override render() and clear().

# layer_cells: Dictionary { layer_name: String -> Array[Vector2i] }
# grid_config: GridConfig
# layers: Dictionary { layer_name: String -> GridLayer }
func render(layer_cells: Dictionary, grid_config: GridConfig, layers: Dictionary) -> void:
	push_error("BaseRenderer.render() must be overridden by subclass")

func clear() -> void:
	push_error("BaseRenderer.clear() must be overridden by subclass")
