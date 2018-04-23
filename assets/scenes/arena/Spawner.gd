extends Spatial

const TRIGGER_LENGTH = 1
const START_HEIGHT = 10

var enemies
var trigger_time = -1

func _ready():
	enemies = $Enemies
	for child in enemies.get_children():
		child.set_process(false)
		child.set_physics_process(false)
		enemies.translation.y = START_HEIGHT
		enemies.visible = false

func _process(delta):
	if trigger_time > 0:
		trigger_time -= delta
		if trigger_time < 0:
			trigger_time = 0
			activate_enemies()
		enemies.translation.y = pow(trigger_time / TRIGGER_LENGTH, 2) * START_HEIGHT

func activate_enemies():
	for child in enemies.get_children():
		child.set_process(true)
		child.set_physics_process(true)


func _on_Area_body_entered(body):
	if body.has_method("type_player") and trigger_time == -1:
		trigger_time = TRIGGER_LENGTH
		enemies.visible = true
