extends Node

@export var starting_wave := 1
## The value of the starting wave for enemy spawning calcs
@export var starting_wave_weight = 5
## The value added by each wave for enemy spawning calcs
@export var wave_increment = 1

## How many grid columns the cells will slide in from on wave start
@export var animation_grid_offset = 10
## The duration of the animation in seconds
@export var animation_duration := 2.0

var current_wave := starting_wave
var current_wave_weight := 5

var enemy_scenes: Array[Enemy] = []

# grid animation handling
var time_elapsed := 0.0
var moving := false

var area_loaded := false
var grid_loaded := false
@onready var enemy_area: EnemyArea
@onready var grid: Sprite2D

func get_wave():
	return current_wave

func _start_wave():
	SignalBus.wave_start.emit(current_wave)
	_generate_wave()
	moving = true
	time_elapsed = 0.0
	current_wave_weight += wave_increment


func _generate_wave():
	var wave_point_total = 0
	var possible_enemies := _get_possible_wave_enemies()

	while wave_point_total < current_wave_weight || possible_enemies.size():
		if (!possible_enemies.size()):
			break

		var index = randi() % possible_enemies.size()
		var enemy := possible_enemies[index]

		# Remove the enemy if it's no longer a valid target
		if enemy.spawn_value > current_wave_weight - wave_point_total:
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
	for path in FilePaths.ENEMY_PATHS:
		var packed_scene = load(path)
		if packed_scene:
			enemy_scenes.push_back(packed_scene.instantiate())

func _sort_enemy_scenes_by_var(variable: String, desc = false):
	enemy_scenes.sort_custom(func(a, b):
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

	for enemy: Enemy in enemy_scenes:
		if enemy.first_available_wave > current_wave:
			continue
		if enemy.spawn_value <= current_wave_weight:
			wave_enemy_array.push_back(enemy)
		else:
			break

	return wave_enemy_array

func _on_enemies_cleared():
	SignalBus.wave_end.emit(current_wave)
	wave_setup_timer()
	current_wave += 1
	_start_wave()
	
func wave_setup_timer() -> void:
	get_tree().create_timer(0.1).timeout.connect(wave_setup_timeout)
	
func wave_setup_timeout() -> void:
	SignalBus.wave_setup_phase.emit()

func setup_controller():
	_get_enemy_scenes()
	_sort_enemy_scenes_by_var("spawn_value")

	if current_wave > 1:
		current_wave_weight += (current_wave - 1) * wave_increment

	_start_wave()

	if !SignalBus.enemies_cleared.is_connected(_on_enemies_cleared):
		SignalBus.enemies_cleared.connect(_on_enemies_cleared)


func initialise_vars() -> void:
	current_wave = starting_wave
	current_wave_weight = starting_wave_weight
	time_elapsed = 0.0
	moving = false
	area_loaded = false
	grid_loaded = false
	enemy_area = null
	grid = null

func reset() -> void:
	print("Resetting WaveController")
	initialise_vars()

func _process(delta: float) -> void:
	if (moving):
		time_elapsed += delta

		if (time_elapsed > animation_duration):
			moving = false
			SignalBus.animation_end.emit()
		else:
			var eased_t = (0.5 - 0.5 * cos((time_elapsed / animation_duration) * PI))
			SignalBus.animation_wave_t.emit(eased_t)

func _on_enemy_area_loaded(area: EnemyArea):
	enemy_area = area
	area_loaded = true
	if grid_loaded:
		setup_controller()


func _on_grid_loaded(grid_node: Sprite2D):
	grid = grid_node
	grid_loaded = true
	if area_loaded:
		setup_controller()

func _ready():
	SignalBus.wave_controller_enemy_area_loaded.connect(_on_enemy_area_loaded)
	SignalBus.wave_controller_grid_loaded.connect(_on_grid_loaded)
