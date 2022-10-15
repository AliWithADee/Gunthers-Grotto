extends TileMap

const START_ALIVE_CHANCE = 40 # % chance for tile to begin alive
const MIN_ALIVE = 3 # minimum alive neighbours to stay alive
const MIN_BIRTH = 5 # minimum alive neighbours to become alive

const ROCK = 0 # Tile 

onready var ground_layer = get_parent().get_node("GroundLayer")
onready var walls_layer = get_parent().get_node("WallsLayer")
onready var objects = get_parent().get_node("Objects")
onready var minimap = get_parent().get_parent().get_node("HUD/UI/Minimap")

# Initialises random grid of rock tiles
func initialise_rock_layer():
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile = ROCK if GameManager.percent_chance(START_ALIVE_CHANCE) else -1
			
			# Create a border of rock tiles with a width of 3
			if x < 3 or x > Globals.CAVE_SIZE-4 or y < 3 or y > Globals.CAVE_SIZE-4:
				tile = ROCK
			
			set_cell(x, y, tile)

# Returns number of alive (rock) neighbours for a given tile
func num_rock_neighbours(tile_x, tile_y) -> int:
	var count = 0
	# Loop through all x and y offsets (-1, 0 and 1)
	for i in range(-1, 2, 1):
		for j in range(-1, 2, 1):
			# Don't count (0,0) as this is the original tile
			if not (i == 0 and j == 0):
				var x = tile_x+i
				var y = tile_y+j
				if get_cell(x, y) == ROCK: # If rock increase count
					count += 1
	return count

# Carries out the cellular automaton logic
# Returns whether the cave generation has finished or not (true or false)
func carry_out_generation() -> bool:
	var changed_tiles = [] # Store changes to tilemap
	
	for x in range(Globals.CAVE_SIZE):
		for y in range(Globals.CAVE_SIZE):
			var tile = get_cell(x, y)
			if tile == ROCK:
				if num_rock_neighbours(x, y) < MIN_ALIVE: # Tile should "die"
					changed_tiles.append({"x": x, "y": y, "value": -1})
			elif tile != ROCK:
				if num_rock_neighbours(x, y) >= MIN_BIRTH: # Tile should be "born"
					changed_tiles.append({"x": x, "y": y, "value": ROCK})
	
	# Make changes to tilemap
	for tile in changed_tiles:
		set_cell(tile["x"], tile["y"], tile["value"])
	
	# If no changes were made then the generation is finsihed
	return changed_tiles.empty()

# Adds a border outside the map to make the edges blend in with the cave
func initialise_outside_border():
	for x in range(-1, Globals.CAVE_SIZE+1):
		set_cell(x, -1, ROCK)
		set_cell(x, Globals.CAVE_SIZE, ROCK)
	
	for y in range(-1, Globals.CAVE_SIZE+1):
		set_cell(-1, y, ROCK)
		set_cell(Globals.CAVE_SIZE, y, ROCK)

# Destroys the tile at the given tile position and handles subsequent actions,
# as a result of the tile being removed.
func destroy_tile(tile_pos: Vector2, update: bool) -> bool:
	var x = tile_pos.x
	var y = tile_pos.y
	
	if get_cell(x, y) != ROCK:
		return false
	if x <= 0 or x >= Globals.CAVE_SIZE-1 or y <= 0 or y >= Globals.CAVE_SIZE-1:
		return false
	
	set_cell(x, y, -1)
	ground_layer.set_cell(x, y, ground_layer.NAVABLE)
	minimap.set_cell(x, y, minimap.GROUND)
	objects.destroy_gemstone_if_present(tile_pos)
	if update:
		walls_layer.update_walls_layer()
		update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
	return true

# Called when the player's mining hurtbox detects the rock layer
func on_player_mine(pos: Vector2) -> bool:
	var tile_pos = world_to_map(pos)
	return destroy_tile(tile_pos, true)

# Called when an explosion detects the rock layer
func on_explosion(pos: Vector2):
	var tile_pos = world_to_map(pos)
	for x in range(-1, 2, 1):
		for y in range(-1, 2, 1):
			var offset = Vector2(x, y)
			destroy_tile(tile_pos + offset, false)
	# Only update ONCE, after all tiles are removed
	walls_layer.update_walls_layer()
	update_bitmask_region(tile_pos-Vector2.ONE, tile_pos+Vector2.ONE)
