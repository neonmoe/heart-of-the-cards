extends Spatial

const FIRE_DAMAGE_INTERVAL = 0.5
const DYING_TIME = 0.15
const FROZEN_SPEED_MULTIPLIER = 0.3

var max_health = 4
var health = max_health
var health_indicator
var dead_time = -1

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

# Something like an alternative super constructor for all enemies
func init(health_, move_speed_):
	max_health = health_
	health = health_
	move_speed = move_speed_

func _ready():
	body = $Body
	player = $"/root/Arena/Player"
	var mesh = $Mesh
	remove_child(mesh)
	body.add_child(mesh)
	health_indicator = $Body/HealthIndicator
	on_fire_indicator = $Body/OnFireIndicator
	frozen_indicator = $Body/FrozenIndicator
	stun_indicator = $Body/StunIndicator

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
	if dead_time == -1:
		health_indicator.scale = Vector3(1, float(health)  / max_health, 1)
		frozen_indicator.visible = frozen_time > 0
		on_fire_indicator.visible = on_fire > 0
		stun_indicator.visible = stun_time > 0
	else:
		health_indicator.visible = false
		frozen_indicator.visible = false
		stun_indicator.visible = false
		on_fire_indicator.visible = false
	
	if health <= 0 and dead_time == -1:
		dead_time = OS.get_ticks_msec() + 1000 * DYING_TIME
	elif dead_time != -1:
		if dead_time <= OS.get_ticks_msec():
			queue_free()
		else:
			var remaining_time = (dead_time - OS.get_ticks_msec()) / DYING_TIME / 1000
			body.scale = Vector3(1, 1, 1) * pow(remaining_time, 0.5)

func _physics_process(delta):
	process_ai(delta)
	var actual_move_speed = move_speed * delta
	if frozen_time > 0:
		actual_move_speed *= FROZEN_SPEED_MULTIPLIER
	if stun_time > 0:
		actual_move_speed *= 0
	body.move_and_slide(move_direction.normalized() * actual_move_speed, Vector3(0, 1, 0))

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

# AI helpers
func towards_player():
	return player.global_transform.origin - body.global_transform.origin
