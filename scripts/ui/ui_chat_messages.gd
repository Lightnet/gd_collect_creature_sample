extends PanelContainer

const UI_CHAT_MESSAGE = preload("res://scenes/ui/ui_chat_message.tscn")
@onready var messages: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer
@onready var scroll_container: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer

#func _ready() -> void:
	#pass

#func _process(delta: float) -> void:
	#pass

func _on_line_edit_text_submitted(new_text: String) -> void:
	#print("msg: ", new_text)
	request_message(new_text)
	#pass

func request_message(msg:String):
	if multiplayer.is_server():
		message.rpc(msg)
	else:
		remote_message.rpc_id(1,msg)
	#pass
	
@rpc("any_peer","call_remote")
func remote_message(msg:String):
	message.rpc(msg)
	#pass
	
@rpc("authority","call_local")
func message(msg:String):
	var dummy = UI_CHAT_MESSAGE.instantiate()
	messages.add_child(dummy)
	dummy.set_message("test", msg)
	
	# Scroll to the bottom
	#var scroll_container = $MarginContainer/VBoxContainer/ScrollContainer
	await get_tree().process_frame # Wait for the next frame to ensure the layout is updated
	scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value
	#pass
