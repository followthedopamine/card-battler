extends Panel
class_name PackOpening

const CARD_SLOTS = 3

@export var card_data: CardData

@export var skip_button: Button
@export var card_area: HBoxContainer

func _ready() -> void:
	SignalBus.pack_opened.connect(_on_pack_opened)
	skip_button.pressed.connect(_on_skip_button_pressed)
	visible = false
	reroll_cards()
	
func _on_pack_opened() -> void:
	open_pack()
	
func _on_skip_button_pressed() -> void:
	visible = false

func open_pack() -> void:
	reroll_cards()
	visible = true

func reroll_cards() -> void:
	for card: Node in card_area.get_children():
		card.queue_free()
	for i: int in range(CARD_SLOTS):
		var new_card: Placeholder = card_data.cards.pick_random().instantiate()
		card_area.add_child(new_card)
		
