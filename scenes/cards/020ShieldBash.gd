extends Card

func activate_card_effect() -> void:
	card_effect.damage = PlayerManager.player_node.block
	super()
	
