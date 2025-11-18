class_name EnemyArea extends Control

@export var enemy_status_tick_rate := 1.0

## The refers to the play area's grid. A left-most col of 0 places the enemies directly to the right of the center line.
@export var left_most_col = 1

var enemy_grid_rows = 4
var enemy_grid_cols = 4

## The Dictionary is `Dictionary[int, bool]` but 'Nested typed collections are not supported.`
##
## key = col, value = row
## this is backwards from normal so I can more easily find the front/back-most cells
var enemy_target_dict: Array[Dictionary] = [{},{},{},{}]

## A grid of enemy nodes that contain the enemy grid's state [row][col]
var enemy_cell_grid: Array[Array] = []

# Using hard coded values because maths is hard :)
var y_position_percentage_offsets = [0.14, 0.32, 0.5, 0.7]

var is_setup := false

@onready var enemy_status_timer := Timer.new()
@onready var grid: Sprite2D = get_tree().get_first_node_in_group("AreaGrid")

@onready var enemy_cell_scene := preload("res://scenes/play_panel/enemy/EnemyCell.tscn")

func add_cell_to_target_grid(grid_pos: Vector2):
	enemy_target_dict[grid_pos.y].set(grid_pos.x, true)

func clear_enemy_from_grid(grid_pos: Vector2):
	enemy_target_dict[grid_pos.y].erase(grid_pos.x)
	
	for col in enemy_target_dict:
		if !col.is_empty():
			return
	
	SignalBus.enemies_cleared.emit()

func get_is_setup():
	return is_setup

func get_random_available_cell(spawn_columns: Array[int]):
	spawn_columns.shuffle()

	for col in spawn_columns:
		var rows = range(enemy_grid_rows)
		rows.shuffle()

		for row in rows:
			if !enemy_cell_grid[row][col].get_has_enemy():
				return enemy_cell_grid[row][col]

	return false
	

func _setup_cells():
	# Clear existing children incase they were mistakenly added
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# setup 4x4 grid
	for row in range(enemy_grid_rows):
		enemy_cell_grid.push_back([])

		for col in range(enemy_grid_cols):
			var current_cell_scene = enemy_cell_scene.instantiate()
			current_cell_scene.set_grid_pos(Vector2(row, col))
			current_cell_scene.z_index = 0
			
			add_child(current_cell_scene)
			enemy_cell_grid[row].push_back(current_cell_scene)

	_position_cells()

func _position_cell(enemy_node: Control, grid_position: Vector2, h_offset: float, vertical_slice: float):
	enemy_node.set_position(Vector2(
		(h_offset + grid_position.y) * (vertical_slice + (vertical_slice * y_position_percentage_offsets[grid_position.x])),
		size.y * y_position_percentage_offsets[grid_position.x])
	)

func _position_cells():
	# Position grid cells to fit within the drawn grid
	var grid_lines = grid.get_lines()
	var odd_offset = 0.0

	grid_lines.x = grid_lines.x / 2

	var h_offset = odd_offset + left_most_col
	var vertical_slice = size.x / grid_lines.x	

	for child in get_children():
		if (child.is_in_group("EnemyCell")):
			_position_cell(child, child.get_grid_pos(), h_offset, vertical_slice)

func _get_target(target: CardEffect.GridTarget):
	var col_range: Array

	match target:
		CardEffect.GridTarget.FRONT:
			col_range = range(0, enemy_grid_rows) 
		CardEffect.GridTarget.BACK:
			col_range = range(enemy_grid_rows - 1, -1, -1)
		CardEffect.GridTarget.RANDOM:
			col_range = range(0, enemy_grid_rows)
			col_range.shuffle()
		CardEffect.GridTarget.NONE:
			return false
	
	for col in col_range:
		var col_dict = enemy_target_dict[col]
		if col_dict.is_empty():
			continue

		var rand_row = randi() % col_dict.size()
		return enemy_cell_grid[col_dict.keys()[rand_row]][col]
	
	return false

func _get_aoe_targets(grid_target: EnemyCell):
	var side_targets: Array[EnemyCell] = []

	for row in range(max(0, grid_target.grid_pos.x - 1), min(enemy_grid_rows, grid_target.grid_pos.x + 1)):
		for col in range(max(0, grid_target.grid_pos.y - 1), min(enemy_grid_cols, grid_target.grid_pos.y + 1)):
			if enemy_cell_grid[row][col].get_has_enemy():
				side_targets.push_back(enemy_cell_grid[row][col])
	print("side_targets:", side_targets.map(func(target): return target.grid_pos))

	return side_targets

func _get_all_targets() -> Array[EnemyCell]:
	var targets: Array[EnemyCell] = []
	for row in enemy_grid_rows:
		for col in enemy_grid_cols:
			if enemy_cell_grid[row][col].get_has_enemy():
				targets.push_back(enemy_cell_grid[row][col])
	return targets

func _on_card_played(card: CardEffect):
	if card.enemy_target_type == card.GridTargetType.ALL:
		for target in _get_all_targets():
			target.process_card_effects(card)
		return
	
	var grid_target: EnemyCell = _get_target(card.enemy_target)

	if (grid_target):
		match card.enemy_target_type:
			card.GridTargetType.SINGLE:
				grid_target.process_card_effects(card)			
			card.GridTargetType.AOE:
				var aoe_targets = _get_aoe_targets(grid_target)
				# This line causes aoe to hit the original target twice
				# This is really hard to display on tooltips
				#grid_target.process_card_effects(card)	
				for target in aoe_targets:
					target.process_card_effects(card)
			

func _on_resized():
	_position_cells()

func _ready() -> void:
	self.connect("resized", _on_resized)
	SignalBus.card_played_target_enemy.connect(_on_card_played)

	# Gives the game time to process the enemy_scene's size
	await get_tree().process_frame
	_setup_cells()
	
	is_setup = true
	SignalBus.enemy_area_setup.emit()
