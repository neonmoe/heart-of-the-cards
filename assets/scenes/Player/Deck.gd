extends Spatial

const DECK_MAX = 40

var camera
var deck_cards = DECK_MAX
var deck_mesh

# Cards
var card_hand
var current_card
var card_drawn = false
var cards

func _ready():
	camera = $Camera
	deck_mesh = $"Left Hand/Deck"
	card_hand = $"Right Hand/CardHolder"
	cards = [ load("res://assets/scenes/Cards/CardFire.tscn") ]

func _process(delta):
	if Input.is_action_just_pressed("throw_card"):
		throw_card()

func throw_card():
	if card_drawn:
		var target = raycast()
		current_card.throw(target)
		card_drawn = false
	if deck_cards > 0:
		draw_card()
		update_mesh()

func draw_card():
	card_drawn = true
	deck_cards -= 1
	current_card = new_card()

func new_card():
	var new_card = cards[randi() % len(cards)].instance()
	card_hand.add_child(new_card)
	new_card.global_transform = card_hand.global_transform
	return new_card

func raycast():
	var from = camera.project_ray_origin(get_viewport().size / 2)
	return from + camera.project_ray_normal(get_viewport().size / 2) * 20

func update_mesh():
	if deck_cards > 0:
		var scale = deck_mesh.scale
		scale.y = float(deck_cards) / DECK_MAX
		deck_mesh.scale = scale
	else:
		deck_mesh.visible = false
