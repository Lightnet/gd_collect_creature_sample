extends Button

func _ready() -> void:
	pressed.connect(btn_test)
	#pass
	
func btn_test():
	Global.notify_message("test")
	#pass
