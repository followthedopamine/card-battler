extends Panel

const WAVE_TEXT_PREFIX: String = "You defeated wave: "

@export var wave_text: RichTextLabel
@export var retry_button: Button

func _ready() -> void:
	visible = false
	SignalBus.player_died.connect(_on_player_died)
	SignalBus.wave_end.connect(_on_wave_end)
	retry_button.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_player_died() -> void:
	visible = true
	get_tree().paused = true
	
func _on_wave_end(wave: int) -> void:
	wave_text.text = WAVE_TEXT_PREFIX + str(wave)
