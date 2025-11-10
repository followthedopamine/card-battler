extends Control

@onready var heath_bar = $HealthBar
@onready var player = get_tree().get_first_node_in_group("Player")

func _on_health_change(health: int):
	heath_bar.set_health(health)

func _ready() -> void:
	heath_bar.set_max_health(player.max_health)
	SignalBus.player_health_change.connect(_on_health_change)
