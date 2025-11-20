extends Card

const DISABLED_SECONDS: float = 10.0

func activate_card_effect() -> void:
	super()
	PlayerManager.hand_node.get_all_playable_cards().pick_random().disable_card(DISABLED_SECONDS)
