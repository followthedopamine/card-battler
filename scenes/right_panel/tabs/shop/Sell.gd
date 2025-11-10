class_name Sell extends Panel

const SELL_MULTIPLIER: float = 0.5

@export var price_label: RichTextLabel

func _ready() -> void:
	visible = false
	SignalBus.card_controller_picked_up.connect(_on_card_controller_picked_up)
	SignalBus.card_controller_released.connect(_on_draggable_released, CONNECT_DEFERRED)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if "price" in data:
		PlayerManager.currency += floori(data.price * SELL_MULTIPLIER)
		data.queue_free()

func _on_card_controller_picked_up(card_controller: CardController):
	# We actually might want players to be able to sell card directly from packs
	# if so remove this check
	if !card_controller.get_parent() is Hand:
		return
	if "price" in card_controller:
		price_label.text = "$%s" % floori(card_controller.price * SELL_MULTIPLIER)
		visible = true
	
func _on_draggable_released() -> void:
	visible = false
