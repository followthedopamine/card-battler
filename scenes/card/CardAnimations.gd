extends AnimationPlayer

@onready var parent = get_parent().get_parent()

func _ready() -> void:
	SignalBus.card_played.connect(_on_card_played)

func _on_card_played(card: Card) -> void:
	if card == parent:
		play("play")
