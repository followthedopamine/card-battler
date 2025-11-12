extends PanelContainer

@export var ray_count = 5

func _ready() -> void:
	SignalBus.game_tick.connect(_on_game_tick)


func _on_game_tick(current_tick):
	print("current_tick:", current_tick)
