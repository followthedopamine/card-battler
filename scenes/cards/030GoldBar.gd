extends Card

const GOLD_INCREASE: int = 5

func activate_card_effect() -> void:
	# Multiply by 2 to account for sell value halving
	self.price += GOLD_INCREASE * 2
