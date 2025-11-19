extends Card

const CURRENCY_ADDED: int = 10

func _ready() -> void:
	super()
	card_effect.on_kill_callables = [effect]
	
func effect() -> void:
	PlayerManager.currency += CURRENCY_ADDED
