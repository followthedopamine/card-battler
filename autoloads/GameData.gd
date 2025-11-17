extends Node

const CARDS_FOLDER_PATH: String = "res://scenes/cards"

var cards_common: Array[Card]
var cards_uncommon: Array[Card]
var cards_rare: Array[Card]
var cards_all: Array[Card]

func _ready() -> void:
	set_card_scene_arrays()

func set_card_scene_arrays():
	var dir = DirAccess.open(CARDS_FOLDER_PATH)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name:
			if !dir.current_is_dir() && file_name.get_extension() == "tscn":
				var full_path = CARDS_FOLDER_PATH.path_join(file_name)
				var packed_scene = load(full_path)
				var instance = packed_scene.instantiate()
				if instance is Card:
					match instance.rarity:
						Card.Rarity.COMMON:
							cards_common.push_back(instance)
						Card.Rarity.UNCOMMON:
							cards_uncommon.push_back(instance)
						Card.Rarity.RARE:
							cards_rare.push_back(instance)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access enemy paths")
