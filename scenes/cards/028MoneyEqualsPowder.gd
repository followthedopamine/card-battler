extends Card

func _ready() -> void:
	card_effect.on_play_enemy_callables = [effect]
	super()
	
func effect(target: Enemy) -> void:
	self.card_effect.damage = PlayerManager.currency / 2
