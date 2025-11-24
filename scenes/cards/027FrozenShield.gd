extends Card

const DURATION_MULTIPLIER: float = 2

var next_card: Card

func activate_card_effect() -> void:
	super()
	next_card = PlayerManager.hand_node.get_next_card(self)
	if is_instance_valid(next_card) and !next_card.is_queued_for_deletion():
		next_card.duration *= DURATION_MULTIPLIER
