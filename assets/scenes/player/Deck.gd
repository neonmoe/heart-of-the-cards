extends Spatial

const DECK_MAX = 20
const CARD_DRAW_TIME = 0.2

var camera
var deck_mesh
var sfx_draw
var sfx_retrieve
var sfx_throw

# Cards
var card_hand
var current_card
var card_drawn = false
var drawing_card_time = 0
var card_draw_requested = false
var cards = [ 
	load("res://assets/scenes/cards/CardFire.tscn"),
	load("res://assets/scenes/cards/CardIce.tscn"),
	load("res://assets/scenes/cards/CardShock.tscn"),
]
var hand = []
var moving_card_start_position
var moving_card_end_position

# Targeting systems
var targeted_enemies = []

func _ready():
	camera = $Camera
	deck_mesh = $"Left Hand/Deck"
	card_hand = $"Right Hand/CardHolder"
	sfx_draw = $SfxDraw
	sfx_retrieve = $SfxRetrieve
	sfx_throw = $SfxThrow
	for i in range(DECK_MAX):
		var new_card = cards[randi() % len(cards)].instance()
		add_card(new_card)

func add_card(card):
	card.picked_up = true
	if card.get_parent():
		card.get_parent().remove_child(card)
	card_hand.add_child(card)
	card.global_transform = card_hand.global_transform
	var rot = card.rotation_degrees
	var pos = card.translation
	rot.x = 90
	rot.y = 60
	pos.x = len(hand) * 0.01 - 1.5
	pos.z = len(hand) * 0.005 + 0.9
	card.rotation_degrees = rot
	card.translation = pos
	hand.push_front(card)
	if not sfx_retrieve.playing:
		sfx_retrieve.play()

func _process(delta):
	if Input.is_action_just_pressed("throw_card"):
		throw_card()
	if drawing_card_time > 0:
		drawing_card_time -= delta
		if drawing_card_time > 0:
			var progress = pow(drawing_card_progress(), 2)
			var current_pos = (moving_card_end_position - moving_card_start_position) * progress + moving_card_start_position
			current_card.translation = current_pos
		else:
			current_card.translation = moving_card_end_position
	elif card_draw_requested and not card_drawn:
		# Drawing card time is 0 or less, animation over, update card_drawn
		card_drawn = true
		card_draw_requested = false

func drawing_card_progress():
	return (CARD_DRAW_TIME - drawing_card_time) / CARD_DRAW_TIME

func throw_card():
	if card_drawn and current_card:
		var target_enemy = find_closest_enemy()
		if target_enemy != null and current_card != null:
			current_card.throw(weakref(target_enemy))
		else:
			var target = raycast()
			current_card.throw_at(target)
		current_card.get_node("CardBody/Mesh").cast_shadow = 1
		sfx_throw.play()
		
		var previous_transform = current_card.global_transform
		card_hand.remove_child(current_card)
		$"/root/Arena/".add_child(current_card)
		current_card.global_transform = previous_transform
		card_drawn = false
	request_card()

func request_card():
	if not card_draw_requested and len(hand) > 0:
		drawing_card_time = CARD_DRAW_TIME
		card_draw_requested = true
		# Draw card
		sfx_draw.play()
		current_card = hand.pop_front()
		moving_card_start_position = current_card.translation
		var pos = card_hand.translation
		var rot = card_hand.translation
		rot.x -= 90
		current_card.rotation_degrees = rot
		moving_card_end_position = pos


func new_card():
	var new_card = cards[randi() % len(cards)].instance()
	card_hand.add_child(new_card)
	var pos = card_hand.translation
	var rot = card_hand.translation
	rot.x -= 90
	pos.y += 0.2
	new_card.rotation_degrees = rot
	new_card.translation = pos
	new_card.get_node("CardBody/Mesh").cast_shadow = 0
	return new_card

func find_closest_enemy():
	if targeted_enemies.size() == 0:
		return null
	else:
		var closest = targeted_enemies[0]
		var closest_dist = INF
		for i in range(targeted_enemies.size()):
			if targeted_enemies[0].is_queued_for_deletion():
				continue
			var enemy = targeted_enemies[0]
			var dist = (enemy.global_transform.origin - global_transform.origin).length()
			if dist < closest_dist:
				closest = enemy
				closest_dist = dist
		return closest

func raycast():
	var from = camera.project_ray_origin(get_viewport().size / 2)
	return from + camera.project_ray_normal(get_viewport().size / 2) * 50

func deck_is_empty():
	return len(hand) == 0 and not card_drawn and not card_draw_requested

func drop_card():
	if current_card != null and card_drawn:
		current_card.dropped = true
		var transform = current_card.global_transform
		card_hand.remove_child(current_card)
		$"/root/Arena".add_child(current_card)
		current_card.global_transform = transform
		current_card = null
		card_drawn = false
		request_card()

# Signals 

func _on_TargetingArea_body_entered(body):
	if body.get_parent().has_method("homing_target"):
		targeted_enemies.append(body)

func _on_TargetingArea_body_exited(body):
	if body.get_parent().has_method("homing_target"):
		targeted_enemies.erase(body)
