extends MarginContainer
class_name ShopSlot

@export var shop_data: ShopData

@export var buy_button: Button
@export var slot_item: Control

@onready var current_item: Control
@onready var current_item_data: ShopItemData

func _ready() -> void:
	buy_button.pressed.connect(_on_buy_button_pressed)
	restock_item()
	
func _on_buy_button_pressed() -> void:
	buy_item()

func buy_item() -> void:
	if PlayerManager.currency < current_item_data.base_price:
		return
	PlayerManager.currency -= current_item_data.base_price
	if current_item is Relic:
		buy_relic()
		return
	if current_item is Pack:
		buy_pack()
		return
	
func buy_relic() -> void:
	SignalBus.relic_added.emit(current_item)
	# If we call restock here the relic will be destroyed after it's reparented
	create_item()
	
func buy_pack() -> void:
	SignalBus.pack_opened.emit()
	restock_item()

func restock_item() -> void:
	# Okay so there are a few options here.
	# 1. Find a way to make sure all instances of an item have an image associated with them
	# and then use that image to display in the shop.
	# 2. Create an instance of the item in the shop and work around the weird typing.
	# 3. Add an image to all the ShopItemData items.
	# Going to start with 2 for now, seems the best mix of flexible and low dev time.
	
	# A potential flaw with this option is that nodes will have to be freed and instantiated
	# which is pretty terrible way to manage memory. It shouldn't have a noticable impact on 
	# performance though unless there are 100s of shop slots.
	destroy_item()
	create_item()

func destroy_item() -> void:
	if current_item != null:
		current_item.queue_free()
	
func create_item() -> void:
	current_item_data = shop_data.shop_items.pick_random()
	buy_button.text = str(current_item_data.base_price)
	var new_item_instance: Node = current_item_data.item.instantiate()
	slot_item.add_child(new_item_instance)
	current_item = new_item_instance
	
