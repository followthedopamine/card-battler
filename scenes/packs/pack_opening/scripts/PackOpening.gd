extends Panel
class_name PackOpening

const CARD_SLOTS = 3
const RARE_ODDS: float = 1.0/10.0
const UNCOMMON_ODDS: float = 1.0/5.0

#@export var card_data: CardData
@export var card_scene: PackedScene

@export var skip_button: Button
@export var card_area: HBoxContainer

func _ready() -> void:
	SignalBus.pack_opened.connect(_on_pack_opened)
	SignalBus.card_chosen.connect(_on_card_chosen)
	skip_button.pressed.connect(_on_skip_button_pressed)
	close_pack()
	reroll_cards()
	
func _on_pack_opened() -> void:
	open_pack()
	
func _on_card_chosen(_card: Card) -> void:
	close_pack()
	
func _on_skip_button_pressed() -> void:
	close_pack()

func open_pack() -> void:
	reroll_cards()
	visible = true
	
func close_pack() -> void:
	visible = false
	SignalBus.pack_closed.emit()

func reroll_cards() -> void:
	for card: Node in card_area.get_children():
		card.queue_free()
	for i: int in range(CARD_SLOTS):
		var rare_chance: float = randf()
		var card_pool: Array[Card] = GameData.cards_common
		if rare_chance < RARE_ODDS:
			card_pool = GameData.cards_rare
		elif rare_chance < UNCOMMON_ODDS:
			card_pool = GameData.cards_uncommon
		var new_card: Card = card_pool.pick_random().duplicate()
		card_area.add_child(new_card)
		
