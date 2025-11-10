extends PanelContainer

var wave = 0

func get_wave():
	return wave

func _setup_wave():
	wave += 1
	SignalBus.wave_start.emit(wave)

func __ready():
	_setup_wave()
