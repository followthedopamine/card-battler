extends VBoxContainer
class_name Shop

const REROLL_PRICE: int = 5

@export var shop_slots: Array[ShopSlot]
@export var shop_reroll_button: Button
	
func _ready() -> void:
	shop_reroll_button.pressed.connect(_on_shop_reroll_button_pressed)
	
func _on_shop_reroll_button_pressed() -> void:
	if PlayerManager.currency >= REROLL_PRICE:
		PlayerManager.currency -= REROLL_PRICE
		for shop_slot: ShopSlot in shop_slots:
			shop_slot.restock_item()
