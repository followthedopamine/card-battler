extends Card

func activate_card_effect() -> void:
	var effected_card: Card = PlayerManager.hand_node.get_next_card(self)
	# If the card is another burn wave it compounds the burn
	if effected_card == null or effected_card.card_name == self.card_name:
		return
	effected_card.card_effect.poison += card_effect.poison
