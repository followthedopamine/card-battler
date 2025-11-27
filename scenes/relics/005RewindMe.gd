extends Relic


	
func _on_card_controller_position_changed() -> void:
	disable_first_card()
	
func added_effect() -> void:
	SignalBus.card_controller_position_changed.connect(_on_card_controller_position_changed)
	disable_first_card()
	
func card_played_effect(_card: Card) -> void:
	if PlayerManager.hand_node.get_child_count():
		if randf() >= 0.4:
			PlayerManager.hand_node.get_child(0).activate_card_effect()

func disable_first_card() -> void:
	if PlayerManager.hand_node.get_child_count():
		for card: Card in PlayerManager.hand_node.get_children():
			if !card.is_disabled:
				continue
			if !card.disabled_timer.paused:
				continue
			card.enable_card()
		var first_card: Card = PlayerManager.hand_node.get_child(0)
		first_card.disable_card(1.0)
		first_card.disabled_timer.paused = true
