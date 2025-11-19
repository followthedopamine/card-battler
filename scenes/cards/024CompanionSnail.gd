extends Card

var effected_card: Card
var original_duration: float

func activate_card_effect() -> void:
	effected_card = PlayerManager.hand_node.get_next_card(self)
	if effected_card == null:
		return
	
	original_duration = effected_card.duration
	effected_card.duration = Card.INSTANT_SPEED
	effected_card.add_on_play_callable(reset_duration)

func reset_duration() -> void:
	effected_card.duration = original_duration
