extends Spatial

const SPEED = 20

var flying_dir

var body

func _ready():
	body = $CardBody
	$CardBody/HomingArea.scale = Vector3(2, 2, 2)
	var mesh = $Mesh
	remove_child(mesh)
	body.add_child(mesh)

func _physics_process(delta):
	if flying_dir != null:
		var collision = body.move_and_collide(flying_dir.normalized() * delta * SPEED)
		if collision != null and (hit(collision.collider) or hit(collision.collider.get_parent())):
			queue_free()

func throw(throw_target):
	look_at(throw_target, Vector3(0, 1, 0))
	flying_dir = throw_target - body.translation

func hit(collider):
	pass

func _on_HomingArea_body_entered(body):
	pass
	
func _on_HomingArea_body_exited(body):
	pass
