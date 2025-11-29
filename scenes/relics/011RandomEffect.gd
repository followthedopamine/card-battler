extends Relic

const EXTRA_DURATION: float = 1.0

func added_effect() -> void:
	add_duration_to_all_cards_in_hand()
		
func card_chosen_effect(card: Card) -> void:
	card.duration += EXTRA_DURATION
	card.original_duration += EXTRA_DURATION

func card_played_effect(_card: Card) -> void:
	# Random card effect
	GameData.cards_all.pick_random().activate_card_effect()

func add_duration_to_all_cards_in_hand() -> void:
	for card: Card in PlayerManager.hand_node.cards:
		card.original_duration += EXTRA_DURATION
		card.duration += EXTRA_DURATION
