extends Panel
class_name PackOpening

const CARD_SLOTS = 3

@export var card_data: CardData
@export var card_scene: PackedScene

@export var skip_button: Button
@export var card_area: HBoxContainer

func _ready() -> void:
	SignalBus.pack_opened.connect(_on_pack_opened)
	SignalBus.card_chosen.connect(_on_card_chosen)
	skip_button.pressed.connect(_on_skip_button_pressed)
	visible = false
	reroll_cards()
	
func _on_pack_opened() -> void:
	open_pack()
	
func _on_card_chosen(_card: Card) -> void:
	visible = false
	
func _on_skip_button_pressed() -> void:
	visible = false

func open_pack() -> void:
	reroll_cards()
	visible = true

func reroll_cards() -> void:
	for card: Node in card_area.get_children():
		card.queue_free()
	for i: int in range(CARD_SLOTS):
		#var new_card: Placeholder = card_data.cards.pick_random().instantiate()
		#var new_card: Card = card_scene.instantiate()
		#new_card.set_colour(randi_range(0, new_card.colours.size()))
		#card_area.add_child(new_card)
		var new_card: Card = card_data.cards.pick_random().instantiate()
		card_area.add_child(new_card)
		
