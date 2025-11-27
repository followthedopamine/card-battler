extends Relic

func card_played_effect(_card: Card) -> void:
	Status.new(Status.Type.STRENGTH, 1, PlayerManager.player_node)
