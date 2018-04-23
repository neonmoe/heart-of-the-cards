extends Spatial

const MOVEMENT_SPEED = 250
const JUMP_SPEED = 300
const SPRINT_SPEED_MULTIPLIER = 1.4

var head
var deck
var sfx_footsteps
var sfx_jump

var gravity
var current_velocity

var exit_countdown = 3

func _ready():
	head = $Head
	deck = $Head/Deck
	sfx_footsteps = $SfxFootsteps
	sfx_jump = $SfxJump
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
	if Input.is_action_pressed("sprint"):
		move *= SPRINT_SPEED_MULTIPLIER
	if move.length() > 0:
		# Moving, play footsteps
		if not sfx_footsteps.playing:
			sfx_footsteps.play()
	else:
		sfx_footsteps.stop()
	
	current_velocity.x = move.x
	current_velocity.z = move.z
	if is_on_floor():
		current_velocity.y = 0
		if Input.is_action_pressed("jump"):
			current_velocity.y += JUMP_SPEED
			sfx_jump.play()
	else:
		current_velocity += gravity
	
	move_and_slide(current_velocity * delta, Vector3(0, 1, 0))
	
	if Input.is_action_just_pressed("toggle_mouse_lock"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if deck.deck_is_empty():
		$Control/LoseLabel.visible = true
		$Control/LoseCountdown.visible = true
		$Control/LoseCountdown.text = str(ceil(exit_countdown))
		exit_countdown -= delta
		if exit_countdown <= 0:
			get_tree().quit()

func _input(event):
	if event is InputEventMouseMotion:
		var body_rot = rotation_degrees
		body_rot.y -= event.relative.x * 0.1
		rotation_degrees = body_rot
		
		var head_rot = head.rotation_degrees
		head_rot.x = clamp(head_rot.x - event.relative.y * 0.07, -90, 90)
		head.rotation_degrees = head_rot

func player_take_damage():
	deck.drop_card()
	deck.request_card()

func add_to_deck(card):
	deck.add_card(card)

func type_player():
	pass


func _on_CardPickupArea_body_entered(body):
	if body.has_method("type_card"):
		var card = body.get_parent()
		if not card.picked_up:
			add_to_deck(body.get_parent())
