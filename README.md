# GridManager2D

A Godot 4 addon for rendering configurable grid overlays in turn-based 2D games. Supports both **square and hexagonal grids** with two rendering backends: **Canvas** (for simple, lightweight rendering) and **TileMap** (for tile-based environments). Perfect for tactical RPGs, roguelikes, and board game simulators.

## Installation

1. Clone this repository into your project's `addons/` directory:
   ```bash
   cd your_project
   git submodule add <repo-url> addons/GridManager2D
   ```

2. Enable the plugin in Godot:
   - Open **Project Settings > Plugins**
   - Find **GridManager2D** and set its status to **Enabled**

3. The `GridManager` node type will now be available in the Scene tree.

## Quick Start

1. **Add a GridManager node** to your scene
2. **Configure in the Inspector:**
   - `Backend`: Choose `Canvas` or `TileMap`
   - `Tile Shape`: Choose `Square` or `Hex`
   - `Cell Size`: Set dimensions (e.g., `64x64`)
   - `Grid Origin`: Offset from node position (default `0, 0`)

3. **Define layers** in the Inspector as a Dictionary:
   ```gdscript
   layers = {
       "movement": GridLayer.new(),
       "interaction": GridLayer.new(),
   }
   ```

4. **Render cells** by calling:
   ```gdscript
   grid_manager.show_layer("movement", [Vector2i(0, 0), Vector2i(1, 0)])
   ```

## Backends

### Canvas Backend

Renders grid cells directly using Godot's `draw_*()` methods. Lightweight and suitable for simple overlays.

**GridLayer properties:**
- `fill_color: Color` — Cell fill color (default: light blue with alpha)
- `border_color: Color` — Cell border color (default: white)
- `border_width: float` — Border width in pixels (default: 2.0)

### TileMap Backend

Renders grid cells as a tilemap, using tiles from a TileSet. Each layer creates a separate `TileMapLayer` child node.

**GridLayer properties (TileMap only):**
- `tile_set: TileSet` — **Required.** The TileSet resource to render from
- `tile_source_id: int` — Source ID within the TileSet (default: 0)
- `tile_atlas_coords: Vector2i` — Tile coordinates in the atlas (default: 0, 0)

**Shared GridLayer properties:**
- `z_index: int` — Render order (default: 0)
- `visible: bool` — Layer visibility (default: true)

## API Reference

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `show_layer()` | `layer_name: String`<br>`cells: Array[Vector2i]` | void | Display cells for a layer. Creates the layer if needed. |
| `hide_layer()` | `layer_name: String` | void | Hide a layer without clearing its cells. |
| `clear_layer()` | `layer_name: String` | void | Clear all cells from a layer and hide it. |
| `clear_all()` | — | void | Clear all cells from all layers. |
| `world_to_cell()` | `world_pos: Vector2` | Vector2i | Convert world coordinates to grid cell. |
| `cell_to_world()` | `cell: Vector2i` | Vector2 | Convert grid cell to world center position. |

All methods validate layer names and emit `push_warning()` for unknown layers (not errors, per project convention).

## Hex Grids

GridManager2D uses **pointy-top** hexagons with **odd-row offset** addressing.

### Coordinate System

- **Column (x):** Increases left-to-right
- **Row (y):** Increases top-to-bottom
- Odd rows (1, 3, 5, ...) are offset **right** by half a cell width

### Cell Size Interpretation

For hex grids, `cell_size` is interpreted as:
- **`cell_size.x`:** Full width of one hex cell (center-to-center horizontal distance)
- **`cell_size.y`:** Full height of one hex cell (without the 0.75 scaling applied internally)

Example: `cell_size = (64, 64)` creates hexagons where columns are 64 pixels apart, and rows are spaced 48 pixels apart vertically (64 * 0.75).

### Conversion Functions

Use the world/cell conversion methods to handle the hexagonal math automatically:

```gdscript
var cell = grid_manager.world_to_cell(world_position)
var world_pos = grid_manager.cell_to_world(cell)
```

The implementation uses `posmod()` for correct handling of negative row indices.

## Development

### Setup

1. Open `project.godot` in **Godot 4.6**
2. Enable the plugin: **Project Settings > Plugins > GridManager2D**
3. Open `main.tscn` in the editor
4. Press **F5** to run

### Running Tests

This project uses the **GUT** testing framework. Run all tests:

```bash
cd /path/to/GridManager2d
godot --headless -s addons/gut/gut_cmdln.gd
```

Test files are located in `tests/` and cover:
- Canvas renderer drawing
- TileMap renderer layer creation
- GridManager coordinate math and API

## License

See LICENSE file in the repository.
