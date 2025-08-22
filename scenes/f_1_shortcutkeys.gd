extends Panel

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("f1"):
		visible = not visible
	
	pass
