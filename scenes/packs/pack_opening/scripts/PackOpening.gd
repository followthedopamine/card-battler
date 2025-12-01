extends Panel
class_name PackOpening

enum Rarity { COMMON, UNCOMMON, RARE }

const CARD_SLOTS = 3

## Odds are in order: Common, Uncommon, Rare
const COMMON_PACK_ODDS = [1, 1.0/5.0, 1.0/50.0]
const UNCOMMON_PACK_ODDS = [0, 1, 1.0/4.0]
const RARE_PACK_ODDS = [0, 0, 1]

## Order: Common, Uncommon, Rare
const ODDS_ARRAY = [COMMON_PACK_ODDS, UNCOMMON_PACK_ODDS, RARE_PACK_ODDS]

#@export var card_data: CardData
@export var card_scene: PackedScene

@export var skip_button: Button
@export var card_area: HBoxContainer

var cards_are_random: bool = false

func _ready() -> void:
	SignalBus.pack_opened.connect(_on_pack_opened)
	SignalBus.card_chosen.connect(_on_card_chosen)
	SignalBus.relic_added.connect(_on_relic_added)
	skip_button.pressed.connect(_on_skip_button_pressed)
	close_pack()
	
func _on_pack_opened(rarity: Rarity) -> void:
	open_pack(rarity)
	
func _on_card_chosen(_card: Card) -> void:
	close_pack()
	
func _on_skip_button_pressed() -> void:
	SignalBus.button_pressed.emit()
	close_pack()
	
func _on_relic_added(relic: Relic) -> void:
	if "ALL_CARDS_ARE_RANDOM" in relic:
		cards_are_random = true

func open_pack(rarity: Rarity) -> void:
	reroll_cards(rarity)
	
	visible = true
	
func close_pack() -> void:
	visible = false
	SignalBus.pack_closed.emit()

func reroll_cards(rarity: Rarity) -> void:
	for card: Node in card_area.get_children():
		card.queue_free()

	for i: int in range(CARD_SLOTS):
		var rare_chance: float = randf()
		var card_pool: Array[Card] = []

		if cards_are_random:
			card_pool = GameData.cards_all
		else:
			var odds = ODDS_ARRAY[rarity]
			if rare_chance < odds[Rarity.RARE]:
				card_pool = GameData.cards_rare
			elif rare_chance < odds[Rarity.UNCOMMON]:
				card_pool = GameData.cards_uncommon
			else:
				card_pool = GameData.cards_common

		var new_card: Card = card_pool.pick_random().duplicate()
		new_card.mouse_filter = MouseFilter.MOUSE_FILTER_STOP
		new_card.z_index = 10
		card_area.add_child(new_card)
		SignalBus.card_added_to_pack.emit(new_card)
