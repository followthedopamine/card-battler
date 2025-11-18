extends Card

@export var increase_amount: int = 1
@onready var original_shield = card_effect.shield

func _ready() -> void:
	super()
	SignalBus.wave_end.connect(_on_wave_end)
	
func _on_wave_end(_wave: int) -> void:
	card_effect.shield = original_shield

func activate_card_effect() -> void:
	super()
	card_effect.shield += increase_amount
