extends Control
@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar


#func _ready() -> void:
	#pass

#func _process(delta: float) -> void:
	#pass

func set_progress(percent:float):
	progress_bar.value = percent
	#pass
