extends Button

@export var game_scene: PackedScene

func _on_pressed():
	SignalBus.game_started.emit()
	SignalBus.button_pressed.emit()
	get_tree().change_scene_to_file(game_scene.get_path())
	

func _ready() -> void:
	pressed.connect(_on_pressed)
