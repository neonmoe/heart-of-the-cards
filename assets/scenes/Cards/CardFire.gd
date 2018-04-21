extends KinematicBody

const SPEED = 30

var flying_dir

func _ready():
	pass

func _process(delta):
	if flying_dir != null:
		var collision = move_and_collide(flying_dir * delta * SPEED)
		if collision != null:
			queue_free()

func throw(target):
	look_at(target, Vector3(0, 1, 0))
	flying_dir = (target - translation).normalized()
