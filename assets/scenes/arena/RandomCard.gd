extends Spatial

var cards = [ 
	load("res://assets/scenes/cards/CardFire.tscn"),
	load("res://assets/scenes/cards/CardIce.tscn"),
	load("res://assets/scenes/cards/CardShock.tscn"),
]

var card_ref
var movement = Vector3()
var sound_delay = (randi() % 100) / 1000.0

func _ready():
	var new_card = cards[randi() % len(cards)].instance()
	new_card.scale *= 1.5
	new_card.translation += Vector3(0, 0.4, 0)
	add_child(new_card)
	card_ref = weakref(new_card)

func move():
	movement = Vector3((randi() % 100) / 50.0 - 1.0, (randi() % 100) / 50.0, (randi() % 100) / 50.0 - 1.0)
	movement = movement.normalized() * 5


func _process(delta):
	if sound_delay > 0:
		sound_delay -= delta
		if sound_delay <= 0:
			$SfxSpawn.play()
			sound_delay = 0
			move()
	else:
		var card = card_ref.get_ref()
		if card and card.get_parent() == self:
			var pos = card.translation
			if pos.y > 0.3:
				pos += movement * delta
				movement.y -= 9.8 * delta
			else:
				pos.y = sin(OS.get_ticks_msec() / 300.0) * 0.1 + 0.2
			card.translation = pos
