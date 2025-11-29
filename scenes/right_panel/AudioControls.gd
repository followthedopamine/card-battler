extends VBoxContainer

@export var sfx_slider: Slider
@export var music_slider: Slider

func _ready() -> void:
	sfx_slider.set_value_no_signal(AudioServer.get_bus_volume_db(AudioController.sfx_bus_index))
	music_slider.set_value_no_signal(AudioServer.get_bus_volume_db(AudioController.music_bus_index))
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	
func _on_sfx_slider_value_changed(value: float) -> void:
	SignalBus.sfx_volume_changed.emit(value)
	
func _on_music_slider_value_changed(value: float) -> void:
	SignalBus.music_volume_changed.emit(value)
