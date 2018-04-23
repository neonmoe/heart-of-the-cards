extends Spatial

var start_time
var won = false

func _ready():
	start_time = OS.get_unix_time()

func show_victory():
	for child in get_parent().get_node("Control").get_children():
		child.visible = true
	var time = OS.get_unix_time() - start_time
	var minutes = time / 60
	var seconds = time % 60
	get_parent().get_node("Control/Time").text = str(minutes) + " min " + str(seconds) + " sec"
	get_parent().get_node("Control/CardsLeft").text = str(len(get_parent().get_node("Player/Head/Deck").hand)) + " cards left"

func _on_Area_body_entered(body):
	if not won and body.has_method("type_player"):
		won = true
		show_victory()
