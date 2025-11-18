extends Card

func activate_card_effect() -> void:
	super()
	add_shield()

func add_shield() -> void:
	PlayerManager.player_node.block += card_effect.shield
