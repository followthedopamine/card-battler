extends Card

const DISABLED_SECONDS: float = 10.0

func activate_card_effect() -> void:
	super()
	var random_card = PlayerManager.hand_node.get_all_playable_cards().pick_random()
	if random_card:
		random_card.disable_card(DISABLED_SECONDS)
