extends Card

const CURRENCY_ADDED: int = 10

func _enter_tree() -> void:
	card_effect.on_kill_callables = [effect]

func effect() -> void:
	print("Kill effect called")
	PlayerManager.currency += CURRENCY_ADDED
