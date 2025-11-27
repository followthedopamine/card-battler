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
	var dir = DirAccess.open(CARDS_FOLDER_PATH)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name:
			if !dir.current_is_dir() && file_name.get_extension() == "tscn":
				var full_path = CARDS_FOLDER_PATH.path_join(file_name)
				var packed_scene = load(full_path)
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

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access enemy paths")
		
func set_relic_scene_array():
	var dir = DirAccess.open(RELIC_FOLDER_PATH)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name:
			if !dir.current_is_dir() && file_name.get_extension() == "tscn":
				var full_path = RELIC_FOLDER_PATH.path_join(file_name)
				var packed_scene = load(full_path)
				var instance: Relic = packed_scene.instantiate()
				
				if instance is Relic:
					relics.push_back(instance)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access enemy paths")
