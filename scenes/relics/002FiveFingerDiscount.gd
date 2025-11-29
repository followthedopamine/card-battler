extends Relic

const SECOND_TO_LAST_CARD_INDEX: int = 3
const LAST_CARD_INDEX: int = 4
const MAX_HAND_SIZE: int = 5
const INSTANT_CARD_SPEED: float = 0.1

func card_played_effect(card: Card) -> void:
	var hand: Hand = PlayerManager.hand_node
	if hand.get_child_count() != MAX_HAND_SIZE:
		return
	var cards: Array = hand.get_children()
	if cards.find(card) == SECOND_TO_LAST_CARD_INDEX:
		cards[LAST_CARD_INDEX].duration = INSTANT_CARD_SPEED
