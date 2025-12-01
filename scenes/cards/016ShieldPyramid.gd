extends Card

@export var increase_amount: int = 5
@export var original_shield: int = 3

var current_stacks = 0
var max_stacks = 3

func _ready() -> void:
	card_effect.shield = original_shield
	super()
	
func _on_wave_end(wave: int) -> void:
	super(wave)
	card_effect.shield = original_shield
	current_stacks = 0

func activate_card_effect() -> void:
	super()
	if current_stacks < max_stacks:
		current_stacks += 1
		card_effect.shield += increase_amount
