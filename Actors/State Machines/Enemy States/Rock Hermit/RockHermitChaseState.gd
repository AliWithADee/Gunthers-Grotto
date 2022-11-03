class_name RockHermitChaseState
extends RockHermitState

const TEXTURE_RIGHT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Right.png")
const TEXTURE_LEFT = preload("res://Assets/Actors/Enemies/Rock_Hermit_Left.png")
const MAX_SPEED = 3000
const MAX_STEERING = 5
const AVOID_FORCE = MAX_SPEED
const STOP_DISTANCE = 25

func enter(ctx: Dictionary = {}):
	if not ctx.has("target"): return state_machine.enter_state("Hidden")
	enemy.target = ctx["target"]

func update(delta):
	update_sprite()
	enemy.hurtbox.look_at(enemy.target.position)
#	if enemy.velocity == Vector2.ZERO:
#		# AND has no line of sight of player
#		# Add timer
#		# Switch to "Wander" state
#		state_machine.enter_state("Hidden")

func update_sprite():
	if enemy.target.position.x > enemy.position.x:
		enemy.body_sprite.texture = TEXTURE_RIGHT
	elif enemy.target.position.x < enemy.position.x:
		enemy.body_sprite.texture = TEXTURE_LEFT
	elif enemy.body_sprite.texture != TEXTURE_RIGHT and enemy.body_sprite.texture != TEXTURE_LEFT:
		randomize()
		enemy.body_sprite.texture = TEXTURE_RIGHT if randf() < 0.5 else TEXTURE_LEFT

func physics_update(delta):
	var steering = get_seek_steering(delta)
	steering += enemy.soft_collision.get_push_vector() * AVOID_FORCE * delta
	steering = steering.limit_length(MAX_STEERING)
	
	enemy.velocity += steering
	enemy.velocity = enemy.velocity.limit_length(MAX_SPEED * delta)
	
	enemy.debug_ray.rotation = enemy.velocity.angle()
	enemy.debug_ray.cast_to.x = enemy.velocity.length()

	enemy.velocity = enemy.move_and_slide(enemy.velocity)

func get_seek_steering(delta) -> Vector2:
	var desired_velocity = Vector2.ZERO
	if enemy.position.distance_to(enemy.target.position) > STOP_DISTANCE:
		desired_velocity = get_seek_direction() * MAX_SPEED * delta
	return desired_velocity - enemy.velocity

func get_seek_direction() -> Vector2:
	enemy.target_ray.cast_to = enemy.target.position - enemy.position
	enemy.target_ray.force_raycast_update()
	
	if !enemy.target_ray.is_colliding():
		return enemy.target_ray.cast_to.normalized()
	else:
		for player_scent in enemy.target.scent_trail:
			enemy.target_ray.cast_to = player_scent.position - enemy.position
			enemy.target_ray.force_raycast_update()
	
			if !enemy.target_ray.is_colliding():
				return enemy.target_ray.cast_to.normalized()
	
	return Vector2.ZERO

func take_damage(attacker, damage: int):
	enemy.body_sprite.modulate = Color.red
	enemy.health -= damage
	if enemy.health < 0: enemy.health = 0
	yield(get_tree().create_timer(0.1), "timeout")
	enemy.body_sprite.modulate = Color.white
	if enemy.health == 0:
		state_machine.enter_state("Dead")
