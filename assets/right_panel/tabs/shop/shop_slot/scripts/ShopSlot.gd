extends MarginContainer
class_name ShopSlot

@export var all_shop_items: ShopData

@export var buy_button: Button
@export var slot_thumbnail: TextureRect

var current_item: ShopItemData


func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	restock_item()
	
func _on_buy_button_pressed() -> void:
	buy_item()

func buy_item() -> void:
	if PlayerManager.currency >= current_item.base_price:
		PlayerManager.currency -= current_item.base_price
		# TODO: Add item transferring
		restock_item()

func restock_item() -> void:
	# Uses less resources to edit the old items instead of assigning a new one to memory
	current_item = all_shop_items.shop_items.pick_random()
	buy_button.text = str(current_item.base_price)
	slot_thumbnail.texture = current_item.thumbnail
