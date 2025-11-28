extends Panel

const WAVE_TEXT_PREFIX: String = "You defeated wave: "

@export var wave_text: RichTextLabel
@export var retry_button: Button

var main: String = "res://scenes/main.tscn"
func _ready() -> void:
	visible = false
	SignalBus.player_died.connect(_on_player_died)
	SignalBus.wave_end.connect(_on_wave_end)
	retry_button.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	get_tree().root.propagate_call("reset")
	get_tree().change_scene_to_file(main)
	
func _on_player_died() -> void:
	visible = true
	get_tree().paused = true
	
func _on_wave_end(wave: int) -> void:
	wave_text.text = WAVE_TEXT_PREFIX + str(wave)
