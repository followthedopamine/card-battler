extends Card

func activate_card_effect() -> void:
	GameData.cards_rare.pick_random().activate_card_effect()
