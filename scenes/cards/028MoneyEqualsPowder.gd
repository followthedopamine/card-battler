extends Card

func _ready() -> void:
	card_effect.on_play_enemy_callables = [effect]
	super()
	
func effect(_target: Enemy) -> void:
	self.card_effect.damage = floor(float(PlayerManager.currency) / 2.0)
