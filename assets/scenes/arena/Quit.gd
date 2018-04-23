extends Spatial

func _on_Area_body_entered(body):
	if body.has_method("type_player"):
		get_tree().quit()
