extends KinematicBody

const FIRE_DAMAGE_INTERVAL = 0.5
const DYING_TIME = 0.15
const FROZEN_SPEED_MULTIPLIER = 0.3

var max_health = 5
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
var move_speed = 200

func _ready():
	health_indicator = $HealthIndicator
	on_fire_indicator = $OnFireIndicator
	frozen_indicator = $FrozenIndicator
	stun_indicator = $StunIndicator

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
			scale = Vector3(1, 1, 1) * pow(remaining_time, 0.5)
	
	process_ai()

func _physics_process(delta):
	var actual_move_speed = move_speed * delta
	if frozen_time > 0:
		actual_move_speed *= FROZEN_SPEED_MULTIPLIER
	if stun_time > 0:
		actual_move_speed *= 0
	move_and_slide(move_direction.normalized() * actual_move_speed, Vector3(0, 1, 0))

func process_ai():
	move_direction = Vector3(cos(OS.get_ticks_msec() / 500.0), 0, sin(OS.get_ticks_msec() / 500.0))

func set_on_fire(stacks):
	on_fire = stacks
	frozen_time = 0

func take_damage(dmg):
	health -= dmg

func freeze(secs):
	frozen_time = secs

func stun(secs):
	stun_time = secs

# For identifying targets for homing cards. Thanks, duck typing >.>
func homing_target():
	pass
