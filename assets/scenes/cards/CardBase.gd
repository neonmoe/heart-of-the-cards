extends Spatial

const FADE_OUT_TIME = 0.1

var speed = 15
var target_ref
var target_dir
var disappear_time = -1

var body

func _ready():
	body = $CardBody
	$CardBody/HomingArea.scale = Vector3(2, 2, 2)
	var mesh = $Mesh
	remove_child(mesh)
	body.add_child(mesh)

func _physics_process(delta):
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
	
	if disappear_time > 0:
		body.scale = Vector3(1, 1, 1) * pow(disappear_time / FADE_OUT_TIME, 0.5)
		disappear_time -= delta
		if disappear_time <= 0:
			queue_free()

func disappear():
	if disappear_time == -1:
		disappear_time = FADE_OUT_TIME

func throw(throw_target):
	target_ref = throw_target

func throw_at(target_pos):
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
