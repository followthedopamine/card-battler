extends Button
var main: String = "res://scenes/main_menu/MainMenu.tscn"
@export var game_scene: PackedScene

func _on_pressed():
	get_tree().change_scene_to_file(main)
	SignalBus.button_pressed.emit()

func _ready() -> void:
	pressed.connect(_on_pressed)
