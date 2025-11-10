extends Card

var base_currency: float = 5

@onready var modified_currency = floori(base_currency * PlayerManager.currency_modifier)

func activate_effect() -> void:
	modified_currency = floori(base_currency * PlayerManager.currency_modifier)
	PlayerManager.currency += modified_currency
