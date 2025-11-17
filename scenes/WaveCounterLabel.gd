extends RichTextLabel

var current_wave = 0

func _on_wave_start(wave: int):
	current_wave = wave
	text = "WAVE " + str(current_wave)

func _ready() -> void:
	SignalBus.wave_start.connect(_on_wave_start)
