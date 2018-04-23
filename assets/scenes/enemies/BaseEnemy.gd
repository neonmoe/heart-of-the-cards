extends Spatial

const FIRE_DAMAGE_INTERVAL = 0.5
const FROZEN_SPEED_MULTIPLIER = 0.3

var max_health = 4
var health = max_health

var on_fire = 0
var fire_cooldown = 0
var on_fire_indicator

var frozen_time = 0
var frozen_indicator

var stun_time = 0
var stun_indicator

var move_direction = Vector3()
var move_speed = 100

var body
var player
var mesh
var sfx_death
var sfx_munch
var sfx_footstep
var last_footstep_side = -1
var offset_pos = Vector3()
var offset_rot = Vector3()
var offset_time = randi() % 100

var random_card = load("res://assets/scenes/arena/RandomCard.tscn")

# Something like an alternative super constructor for all enemies
func init(health_, move_speed_):
	max_health = health_
	health = health_
	body.set_explosion_size(health)
	move_speed = move_speed_

func _ready():
	body = $Body
	player = $"/root/Arena/Player"
	mesh = $Mesh
	remove_child(mesh)
	body.add_child(mesh)
	on_fire_indicator = $Body/OnFireIndicator
	frozen_indicator = $Body/FrozenIndicator
	stun_indicator = $Body/StunIndicator
	sfx_footstep = $Body/SfxFootstep
	sfx_death = $Body/SfxDeath
	sfx_munch = $Body/SfxMunch

func _process(delta):
	if on_fire > 0 and fire_cooldown <= 0:
		fire_cooldown = FIRE_DAMAGE_INTERVAL
		on_fire -= 1
		take_damage(1)
	elif fire_cooldown > 0:
		fire_cooldown -= delta
	
	if frozen_time > 0:
		frozen_time -= delta
	
	if stun_time > 0:
		stun_time -= delta
	
	# Indicators
	frozen_indicator.visible = frozen_time > 0
	on_fire_indicator.visible = on_fire > 0
	stun_indicator.visible = stun_time > 0
	
	if health <= 0:
		body.explode()
		sfx_death.play()
		var prev_transform = sfx_death.global_transform
		body.remove_child(sfx_death)
		$"/root/Arena".add_child(sfx_death)
		sfx_death.global_transform = prev_transform
		var random_cards = randi() % max_health + 2
		for i in range(random_cards):
			var card = random_card.instance()
			$"/root/Arena".add_child(card)
			card.global_transform.origin = body.global_transform.origin
		queue_free()
	
	# Animation
	var osc = sin((offset_time + OS.get_ticks_msec()) / 100.0 * move_speed / 200)
	if not stunned():
		offset_pos.y = 0.45 - min(1, abs(osc) * 3.0) * 0.3
		offset_rot.z = sign(osc) * min(1, abs(osc * 1.5)) * 20
		if last_footstep_side != sign(osc) and abs(osc) >= 0.9:
			sfx_footstep.play()
			last_footstep_side = sign(osc)
	else:
		offset_pos.y = 0
		offset_rot.z = 0
	offset_rot.y = 180
	mesh.translation = offset_pos
	mesh.rotation_degrees = offset_rot

func _physics_process(delta):
	process_ai(delta)
	var actual_move_speed = move_speed * delta * pow(offset_pos.y * 3.5, 2)
	if frozen_time > 0:
		actual_move_speed *= FROZEN_SPEED_MULTIPLIER
	if stun_time > 0:
		actual_move_speed *= 0
	body.move_and_slide(move_direction.normalized() * actual_move_speed, Vector3(0, 1, 0))
	body.look_at(player.global_transform.origin, Vector3(0, 1, 0))

func process_ai(delta):
	move_direction = Vector3(cos(OS.get_ticks_msec() / 200.0), 0, sin(OS.get_ticks_msec() / 200.0))

func take_damage(dmg):
	health -= dmg

func set_on_fire(stacks):
	on_fire = stacks
	frozen_time = 0

func on_fire():
	return on_fire > 0

func freeze(secs):
	frozen_time = secs

func unfreeze():
	frozen_time = 0

func frozen():
	return frozen_time > 0

func stun(secs):
	stun_time = secs

func stunned():
	return stun_time > 0

# For identifying targets for homing cards. Thanks, duck typing >.>
func homing_target():
	pass

func _on_Area_body_entered(body):
	if body.has_method("player_take_damage"):
		body.player_take_damage()
		sfx_munch.play()

# AI helpers
func towards_player():
	return player.global_transform.origin - body.global_transform.origin
