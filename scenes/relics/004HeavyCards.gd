extends Relic

func wave_end_effect(_wave: int) -> void:
	# Very hacky fix but it works for now
	await get_tree().create_timer(0.1).timeout
	PlayerManager.player_node.strength = 0

func card_played_effect(_card: Card) -> void:
	Status.new(Status.Type.STRENGTH, 1, PlayerManager.player_node)
	PlayerManager.player_node.strength += 1
