extends Card

func activate_card_effect() -> void:
	add_shield()
	super()

func add_shield() -> void:
	PlayerManager.player_node.block += card_effect.shield
