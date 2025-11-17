extends Card

func activate_card_effect() -> void:
	Status.new(Status.Type.EXTRA_ATTACK, 1, PlayerManager.player_node)
