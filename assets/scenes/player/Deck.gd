extends Spatial

const DECK_MAX = 20
const CARD_DRAW_TIME = 0.2

var camera
var deck_cards = DECK_MAX
var deck_mesh

# Cards
var card_hand
var current_card
var card_drawn = false
var drawing_card_time = 0
var card_draw_requested = false
var cards

func _ready():
	camera = $Camera
	deck_mesh = $"Left Hand/Deck"
	card_hand = $"Right Hand/CardHolder"
	cards = [ 
		load("res://assets/scenes/cards/CardFire.tscn"),
		load("res://assets/scenes/cards/CardIce.tscn"),
		load("res://assets/scenes/cards/CardShock.tscn")
	]

func _process(delta):
	if Input.is_action_just_pressed("throw_card"):
		throw_card()
	if drawing_card_time > 0:
		drawing_card_time -= delta
	elif card_draw_requested and deck_cards > 0 and not card_drawn:
		draw_card()
		card_draw_requested = false

func throw_card():
	if card_drawn:
		var target = raycast()
		current_card.throw(target)
		$"/root/Arena/".add_child(current_card)
		remove_child(current_card)
		card_drawn = false
	request_card()

func request_card():
	if not card_draw_requested:
		drawing_card_time = CARD_DRAW_TIME
		card_draw_requested = true

func draw_card():
	if deck_cards > 0:
		card_drawn = true
		deck_cards -= 1
		current_card = new_card()
		update_mesh()

func new_card():
	var new_card = cards[randi() % len(cards)].instance()
	card_hand.add_child(new_card)
	var pos = card_hand.translation
	var rot = card_hand.translation
	rot.x -= 90
	pos.y += 0.2
	new_card.rotation_degrees = rot
	new_card.translation = pos
	return new_card

func raycast():
	var from = camera.project_ray_origin(get_viewport().size / 2)
	return from + camera.project_ray_normal(get_viewport().size / 2) * 50

func update_mesh():
	if deck_cards > 0:
		var scale = deck_mesh.scale
		scale.y = float(deck_cards) / DECK_MAX
		deck_mesh.scale = scale
	else:
		deck_mesh.visible = false

func deck_is_empty():
	return deck_cards == 0 and not card_drawn

func drop_card():
	if current_card != null:
		current_card.queue_free()
		remove_child(current_card)
		current_card = null
		card_drawn = false
