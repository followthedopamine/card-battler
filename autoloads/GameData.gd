extends Node

const CARDS_FOLDER_PATH: String = "res://scenes/cards"
const RELIC_FOLDER_PATH: String = "res://scenes/relics"

var cards_common: Array[Card]
var cards_uncommon: Array[Card]
var cards_rare: Array[Card]
var cards_all: Array[Card]

var relics: Array[Relic]

func _ready() -> void:
	set_card_scene_arrays()
	set_relic_scene_array()

func set_card_scene_arrays():
	for path in FilePaths.CARD_PATHS:
		var packed_scene = load(path)
		var instance: Card = packed_scene.instantiate()
		
		if instance is Card:
			match instance.rarity:
				Card.Rarity.COMMON:
					cards_common.push_back(instance)
				Card.Rarity.UNCOMMON:
					cards_uncommon.push_back(instance)
				Card.Rarity.RARE:
					cards_rare.push_back(instance)
			cards_all.push_back(instance)
		
func set_relic_scene_array():
	for path in FilePaths.RELIC_PATHS:
		var packed_scene = load(path)
		var instance: Relic = packed_scene.instantiate()
		
		if instance is Relic:
			relics.push_back(instance)

func reset() -> void:
	print("Resetting game data")
	cards_common = []
	cards_uncommon = []
	cards_rare = []
	cards_all = []
	relics = []
	set_card_scene_arrays()
	set_relic_scene_array()
