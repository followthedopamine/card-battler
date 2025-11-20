extends Card

const BIG_DAMAGE: int = 40

var original_damage: int

func _ready() -> void:
	card_effect.on_play_enemy_callables = [effect]
	original_damage = card_effect.damage
	super()

func effect(target: Entity) -> void:
	if Status.has_status(target, Status.Type.POISON):
		card_effect.damage = BIG_DAMAGE
	else:
		card_effect.damage = original_damage
