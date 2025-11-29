extends Relic

const BLOCK_AMOUNT: int = 1

func wave_end_effect(_wave: int) -> void:
	# Very hacky fix but it works for now
	await get_tree().create_timer(0.1).timeout
	PlayerManager.player_node.block = 0

func card_played_effect(_card: Card) -> void:
	PlayerManager.player_node.block += BLOCK_AMOUNT
