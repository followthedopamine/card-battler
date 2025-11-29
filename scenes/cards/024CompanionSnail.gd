extends Card

var effected_card: Card

func activate_card_effect() -> void:
	effected_card = PlayerManager.hand_node.get_next_card(self)
	if effected_card == null:
		return
	effected_card.duration = Card.INSTANT_SPEED
