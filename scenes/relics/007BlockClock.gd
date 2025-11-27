extends Relic

const BLOCK_AMOUNT: int = 1

func card_played_effect(_card: Card) -> void:
	PlayerManager.player_node.block += BLOCK_AMOUNT
