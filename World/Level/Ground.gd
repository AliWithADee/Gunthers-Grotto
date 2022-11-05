extends TileMap

# Tile references
const GROUND = 0

func update_ground_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			set_cell(x, y, GROUND)
