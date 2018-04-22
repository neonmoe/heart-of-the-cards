extends Spatial

const FADE_OUT_TIME = 0.4
const LIFETIME = 1

var speed = 15
var target_ref
var target_dir

var body
var ice_explosion = false
var is_card = true
var spawn_time
var dropped = false
var dropping_speed = 1
var picked_up = false

func _ready():
	body = $CardBody
	$CardBody/HomingArea.scale = Vector3(2, 2, 2)
	var mesh = $Mesh
	remove_child(mesh)
	body.add_child(mesh)

func _physics_process(delta):
	if dropped:
		dropping_speed -= 9.8 * delta
		body.translation += Vector3(0, 0, dropping_speed * delta)
		if body.global_transform.origin.y <= 0:
			disappear()
	
	if target_ref:
		var target = target_ref.get_ref()
		if target:
			var target_pos = target.global_transform.origin
			target_pos.y += 0.5
			target_dir = target_pos - body.global_transform.origin
		elif target_dir == null:
			# Target has died and we have no direction, disappear
			disappear()
	
	if target_dir != null:
		body.look_at(target_dir, Vector3(0, 1, 0))
		move(delta, target_dir)
	
	# Don't stay in the world for too long
	if (target_ref or target_dir) and (OS.get_ticks_msec() - spawn_time) / 1000.0 > LIFETIME:
		disappear()

func disappear():
	$CardBody.explode(ice_explosion, is_card)
	queue_free()

func throw(throw_target):
	spawn_time = OS.get_ticks_msec()
	$CardBody.start_trail()
	target_ref = throw_target

func throw_at(target_pos):
	spawn_time = OS.get_ticks_msec()
	$CardBody.start_trail()
	target_dir = target_pos - body.global_transform.origin

func move(delta, dir):
	var collision = body.move_and_collide(dir.normalized() * delta * speed)
	if collision != null and (hit(collision.collider) or hit(collision.collider.get_parent())):
		disappear()

func hit(collider):
	pass

func _on_HomingArea_body_entered(body):
	pass
	
func _on_HomingArea_body_exited(body):
	pass

