extends Relic

const WAVES: int = 5
const CURRENCY_MULT: int = 2

var remaining_waves: int = WAVES

func added_effect() -> void:
	relic_components.label.text = str(remaining_waves)

func wave_end_effect(_wave: int) -> void:
	if remaining_waves >= 1:
		remaining_waves -= 1
		relic_components.label.text = str(remaining_waves)
		PlayerManager.currency += WaveController.current_wave * CURRENCY_MULT
		call_deferred("randomise_hand")
	
func randomise_hand() -> void:
	var count = 0
	for card: Card in PlayerManager.hand_node.get_children():
		if is_instance_valid(card) and !card.is_queued_for_deletion():
			card.queue_free()
			count += 1
	for i: int in count:
		var new_card: Card = GameData.cards_all.pick_random().duplicate()
		PlayerManager.hand_node.add_child(new_card)
	PlayerManager.hand_node.start_round()
