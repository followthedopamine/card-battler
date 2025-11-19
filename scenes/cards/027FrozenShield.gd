extends Card

const DURATION_MULTIPLIER: float = 2

var next_card: Card
var original_duration: float

func activate_card_effect() -> void:
	super()
	next_card = PlayerManager.hand_node.get_next_card(self)
	original_duration = next_card.duration
	next_card.duration *= DURATION_MULTIPLIER
	next_card.add_on_play_callable(reset_duration)

func reset_duration() -> void:
	next_card.duration = original_duration
