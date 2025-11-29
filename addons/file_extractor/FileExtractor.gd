@tool
extends EditorPlugin

const FOLDER_PATHS: Dictionary = {
	"CARD_PATHS": "res://scenes/cards",
	"RELIC_PATHS": "res://scenes/relics",
	"ENEMY_PATHS": "res://scenes/play_panel/enemies",
	"AUDIO_PATHS": "res://scenes/audio"
}

const OUTPUT_PATH := "res://autoloads/FilePaths.gd"

func _enable_plugin() -> void:
	_setup_file_paths()
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


func _build():
	_setup_file_paths()
	return true

func _export_begin(features, is_debug, path):
	_setup_file_paths()

func _get_files_from_folder(path: String, file_type := ".tscn"):
	var dir = DirAccess.open(path)
	var files = []

	if dir:
		dir.list_dir_begin()
		var file = dir.get_next()
		while file != "":
			if file.ends_with(".tscn"):
				files.append("%s/" % path + file)
			file = dir.get_next()
		dir.list_dir_end()
	
	return files

func _setup_file_paths():
	var text := "extends Node2D \n\n# AUTO-GENERATED. DO NOT EDIT.\n\n"

	for key in FOLDER_PATHS:
		var entries = _get_files_from_folder(FOLDER_PATHS[key])


		text += "const %s = [\n" % key

		for path in entries:
				text += "	\"%s\",\n" % path
		text += "]\n\n"

	# Save to file
	var out = FileAccess.open(OUTPUT_PATH, FileAccess.WRITE)
	out.store_string(text)
	out.close()

	print("Generated:", OUTPUT_PATH)