extends PanelContainer


func _ready() -> void:
  SignalBus.game_tick.connect(_on_game_tick)


func _on_game_tick(current_tick):
  print("current_tick:", current_tick)