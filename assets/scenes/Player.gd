extends Spatial

const MOVEMENT_SPEED = 250
const JUMP_SPEED = 10

var body
var head
var gravity
var current_velocity

func _ready():
	body = $KinematicBody
	head = $KinematicBody/Head
	gravity = Vector3(0, -18.2, 0)
	current_velocity = Vector3()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	var move = Vector3()
	var cam_direction = head.get_global_transform().basis
	
	if Input.is_action_pressed("move_forward"):
		move += -cam_direction.z.normalized()
	if Input.is_action_pressed("move_back"):
		move += cam_direction.z.normalized()
	if Input.is_action_pressed("move_right"):
		move += cam_direction.x.normalized()
	if Input.is_action_pressed("move_left"):
		move += -cam_direction.x.normalized()
	move.y = 0
	move = move.normalized() * MOVEMENT_SPEED
	
	current_velocity.x = move.x
	current_velocity.z = move.z
	if Input.is_action_just_pressed("jump"):
		current_velocity.y += JUMP_SPEED
	elif body.is_on_floor():
		current_velocity.y = 0
	else:
		current_velocity += gravity
	
	$KinematicBody.move_and_slide(current_velocity * delta)

func _input(event):
	if event is InputEventMouseMotion:
		var body_rot = body.rotation_degrees
		body_rot.y -= event.relative.x * 0.1
		body.rotation_degrees = body_rot
		
		var head_rot = head.rotation_degrees
		head_rot.x = clamp(head_rot.x - event.relative.y * 0.07, -90, 90)
		head.rotation_degrees = head_rot
	if event is InputEventAction and event.action == "toggle_mouse_lock":
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
