extends Card

func _ready() -> void:
	super()
	card_effect.on_play_enemy_callables = [effect]
	
func effect(_target: Enemy) -> void:
	self.card_effect.damage = PlayerManager.currency / 2
