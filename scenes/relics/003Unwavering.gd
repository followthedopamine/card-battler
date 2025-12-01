extends Relic

const DURATION: float = 1.5

func added_effect() -> void:
	SignalBus.card_duration_changed.connect(_on_card_duration_changed)
	SignalBus.card_added_to_pack.connect(_on_card_added_to_pack)
	for card: Card in PlayerManager.hand_node.get_children():
		card.duration = DURATION
		
func _on_card_added_to_pack(card: Card) -> void:
	card.duration = DURATION
	
func _on_card_duration_changed(card: Card) -> void:
	card.duration = DURATION

func card_chosen_effect(card: Card) -> void:
	card.duration = DURATION
