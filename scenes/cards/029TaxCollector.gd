extends Card

const CURRENCY_ADDED: int = 10

func _ready() -> void:
	card_effect.on_kill_callables = [effect]
	super()

func effect() -> void:
	PlayerManager.currency += CURRENCY_ADDED
