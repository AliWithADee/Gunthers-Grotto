extends Node2D

# Node references
onready var walls = $Walls
onready var player = $Objects/Player
onready var cave_exit = $Objects/CaveExit
onready var ceiling = $Ceiling

# HUD
onready var map = $HUD/Map
onready var level_title = $HUD/UI/LevelTitle

func _ready():
	player.connect("exited_cave", self, "on_player_exited_cave")
	
	# Reset the number of caves since the magpie level spawned
	GameManager.caves_since_magpie = 0
	
	# Update the map to display the layout of the magpie level
	map.update_map(walls)
	map.visible = false # Hide the map overlay
	
	# Setup the limits for the player's camera
	var rect = walls.get_used_rect()
	var camera: Camera2D = player.get_camera()
	camera.limit_left = (rect.position.x + 1) * Globals.CAVE_TILE_SIZE
	camera.limit_top = (rect.position.y + 1) * Globals.CAVE_TILE_SIZE
	camera.limit_right = (rect.position.x + rect.size.x - 1) * Globals.CAVE_TILE_SIZE
	camera.limit_bottom = (rect.position.y + rect.size.y - 1) * Globals.CAVE_TILE_SIZE
	
	if LoadingScreen.is_showing():
		yield(LoadingScreen.hide(), "completed")
	level_title.add_title_to_queue("The Magpie")

func _process(delta):
	var canvas_transform = player.get_global_transform_with_canvas()
	map.update_position(canvas_transform.get_origin(), player.position)

# Called when the player enters the CaveExit detection radius
func on_player_exited_cave():
	LoadingScreen.change_scene("res://World/Level/Level.tscn")
