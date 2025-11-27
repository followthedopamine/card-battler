extends Relic

const INSTANT_SPEED: float = 0.1

func wave_end_effect(_wave: int) -> void:
	if PlayerManager.hand_node.get_child_count() > 0:
		call_deferred("make_instant")
		
func make_instant() -> void:
	# TODO: Might wanna make this target the first non disabled card
	PlayerManager.hand_node.get_children()[0].duration = INSTANT_SPEED
	PlayerManager.hand_node.get_children()[0].activate()
