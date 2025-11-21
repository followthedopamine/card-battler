class_name WaveController extends Node

@export var wave = 1
## How many grid columns the cells will slide in from on wave start
@export var animation_grid_offset = 7
## The duration of the animation in seconds
@export var animation_duration := 1.0

@export_dir var enemy_folder_path = "res://scenes/play_panel/enemies"

var enemy_scene_array: Array[Enemy] = []

# grid animation handling
var time_elapsed := 0.0
var moving := false

@onready var enemy_area: EnemyArea = get_tree().get_first_node_in_group("EnemyArea")
@onready var grid: Sprite2D = get_tree().get_first_node_in_group("AreaGrid")

func get_wave():
	return wave

func _start_wave():
	SignalBus.wave_start.emit(wave)
	_generate_wave()
	moving = true
	time_elapsed = 0.0


func _generate_wave():
	var wave_point_total = 0
	var possible_enemies := _get_possible_wave_enemies()

	while wave_point_total < wave || possible_enemies.size():
		if (!possible_enemies.size()):
			break

		var index = randi() % possible_enemies.size()
		var enemy := possible_enemies[index]

		# Remove the enemy if it's no longer a valid target
		if enemy.spawn_value > wave - wave_point_total:
			possible_enemies.remove_at(index)
			continue
		
		var spawn_cell = enemy_area.get_random_available_cell(enemy.spawn_columns)

		if !spawn_cell:
			possible_enemies.remove_at(index)
			continue
		
		spawn_cell.return_to_start_pos()
		spawn_cell.spawn_enemy(enemy.duplicate())
		wave_point_total += enemy.spawn_value

func _get_enemy_scenes():
	var dir = DirAccess.open(enemy_folder_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name:
			if !dir.current_is_dir() && file_name.get_extension() == "tscn":
				var full_path = enemy_folder_path.path_join(file_name)
				var packed_scene = load(full_path)
				if packed_scene:
					enemy_scene_array.push_back(packed_scene.instantiate())

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access enemy paths")

func _sort_enemy_scenes_by_var(variable: String, desc = false):
	enemy_scene_array.sort_custom(func(a, b):
		if variable in a && variable in b:
			if desc:
				return a[variable] > b[variable] 
			else:
				return a[variable] < b[variable] 
	)

## Gets every available enemy with point total below the current wave's value
## Assumes the array is currently sorted by spawn_value
func _get_possible_wave_enemies() -> Array[Enemy]:
	var wave_enemy_array: Array[Enemy] = []

	for enemy: Enemy in enemy_scene_array:
		if enemy.first_available_wave > wave:
			continue
		if enemy.spawn_value <= wave:
			wave_enemy_array.push_back(enemy)
		else:
			break
	
	return wave_enemy_array

## Some of this file's functionality is reliant on the Enemy Area being setup.
func _on_enemy_area_setup():
	_start_wave()

func _on_enemies_cleared():
	SignalBus.wave_end.emit(wave)
	wave += 1
	_start_wave()

func _ready():
	_get_enemy_scenes()
	_sort_enemy_scenes_by_var("spawn_value")

	SignalBus.animation_grid_offset.emit(animation_grid_offset)
		
	if enemy_area.get_is_setup():
		_on_enemy_area_setup()
	else:
		SignalBus.enemy_area_setup.connect(_on_enemy_area_setup)
	
	SignalBus.enemies_cleared.connect(_on_enemies_cleared)

func _process(delta: float) -> void:
	if (moving):
		time_elapsed += delta

		if (time_elapsed > animation_duration):
			moving = false
			SignalBus.animation_end.emit()
		else:
			var eased_t = (0.5 - 0.5 * cos((time_elapsed / animation_duration) * PI))
			SignalBus.animation_wave_t.emit(eased_t)
