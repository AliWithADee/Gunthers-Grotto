class_name Player
extends KinematicBody2D

# Constants
enum Tools { PICKAXE, REVOLVER, DYNAMITE }
const PICKAXE_TEXTURE = preload("res://Assets/Actors/Player/Pickaxe_In_Hand.png")
const REVOLVER_TEXTURE = preload("res://Assets/Actors/Player/Revolver_In_Hand.png")
const DYNAMITE_TEXTURE = preload("res://Assets/Actors/Player/Dynamite_In_Hand.png")

# Node references
onready var body_sprite: Sprite = $BodySprite
onready var item_sprite: Sprite = $ItemSprite
onready var animations: AnimationPlayer = $Animations
onready var hitbox: Area2D = $Hitbox
onready var hurtbox: Area2D = $Hurtbox
onready var pickaxe_cooldown: Timer = $PickaxeCooldown
onready var revolver_cooldown: Timer = $RevolverCooldown
onready var dynamite_cooldown: Timer = $DynamiteCooldown
onready var main_state_machine: StateMachine = $MainStateMachine
onready var action_state_machine: StateMachine = $ActionStateMachine

var velocity = Vector2.ZERO
var facing = Vector2.DOWN
var equipped = Tools.PICKAXE
var scent_trail = []

signal pickaxe_used # Emitted when the player uses their pickaxe
signal exited_cave # Emitted when the player exits the current cave

func _ready():
	$ScentTimer.connect("timeout", self, "leave_scent")

func get_camera() -> Camera2D:
	return get_node("Camera") as Camera2D

func get_feet_position() -> Vector2:
	return get_node("CollisionShape").global_position

# Sets the player's facing direction based on the given direction vector
func set_facing_towards(target_direction: Vector2):
	var facing_before = facing
	facing = Utils.approximate_direction_4_ways(target_direction)
	# Render body sprite above item sprite if facing upwards
	if facing != facing_before:
		if facing == Vector2.UP: move_child(body_sprite, 1)
		else: move_child(body_sprite, 0)

# Equips the given tool and updates the item sprite
func equip(new_tool: int):
	equipped = new_tool
	update_item_sprite()

# Sets the texture of the item sprite to display the currently equipped tool
func update_item_sprite():
	match equipped:
		Tools.PICKAXE: item_sprite.texture = PICKAXE_TEXTURE
		Tools.REVOLVER: item_sprite.texture = REVOLVER_TEXTURE
		Tools.DYNAMITE: item_sprite.texture = DYNAMITE_TEXTURE
		_: item_sprite.texture = null

# Called, usually externally, when the player needs to take damage
func take_damage(attacker, damage: int):
	main_state_machine.call_method("take_damage", [attacker, damage])

# Called when scent timer times out
func leave_scent():
	main_state_machine.call_method("leave_scent")

# Removes all scent trail nodes and clears the scent trail
func clear_scent_trail():
	for scent in scent_trail:
		scent.queue_free()
	scent_trail.clear()

func exit_cave(exit_pos: Vector2):
	main_state_machine.enter_state("ExitCave", {"exit_pos":exit_pos})
