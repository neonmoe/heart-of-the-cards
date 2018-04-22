extends Spatial

var speed = 15
var target
var target_dir

var body

func _ready():
	body = $CardBody
	$CardBody/HomingArea.scale = Vector3(2, 2, 2)
	var mesh = $Mesh
	remove_child(mesh)
	body.add_child(mesh)

func _physics_process(delta):
	if target != null:
		var target_pos = target.global_transform.origin
		target_pos.y += 0.5
		var flying_dir = target_pos - body.global_transform.origin
		body.look_at(flying_dir, Vector3(0, 1, 0))
		move(delta, flying_dir)
	elif target_dir != null:
		move(delta, target_dir)

func throw(throw_target):
	target = throw_target

func throw_at(target_pos):
	target_dir = target_pos - body.global_transform.origin
	body.look_at(target_dir, Vector3(0, 1, 0))

func move(delta, dir):
	var collision = body.move_and_collide(dir.normalized() * delta * speed)
	if collision != null and (hit(collision.collider) or hit(collision.collider.get_parent())):
		queue_free()	

func hit(collider):
	pass

func _on_HomingArea_body_entered(body):
	pass
	
func _on_HomingArea_body_exited(body):
	pass
