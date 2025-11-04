extends Control

var current_tick = 0

func _on_global_timer_timeout() -> void:
	current_tick += 1
	SignalBus.emit_signal("game_tick", current_tick);
