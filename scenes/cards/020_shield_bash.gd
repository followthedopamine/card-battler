extends Card

func activate_card_effect() -> void:
	card_effect.damage = PlayerManager.player_node.block
	PlayerManager.player_node.block -= card_effect.shield
	if PlayerManager.player_node.block < 0:
		PlayerManager.player_node.block = 0
	super()
	
