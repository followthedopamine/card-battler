extends VBoxContainer

@export var sfx_slider: Slider
@export var music_slider: Slider

func _ready() -> void:
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	
func _on_sfx_slider_value_changed(value: float) -> void:
	SignalBus.sfx_volume_changed.emit(value)
	
func _on_music_slider_value_changed(value: float) -> void:
	SignalBus.music_volume_changed.emit(value)
