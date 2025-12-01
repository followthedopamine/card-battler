extends Card

@export var increase_amount: int = 2
@export var start_damage: int = 4

func _ready() -> void:
	card_effect.damage = start_damage - increase_amount
	super()
	
func _on_wave_end(wave: int) -> void:
	super(wave)
	card_effect.damage = start_damage - increase_amount

func activate_card_effect() -> void:
	card_effect.damage += increase_amount
	super()
