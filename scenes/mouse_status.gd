extends Label

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		text = "Mouse Mode: CAPTURED"
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		text = "Mouse Mode: VISIBLE"
