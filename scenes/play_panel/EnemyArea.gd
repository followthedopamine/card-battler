extends Control

@export var enemy_status_tick_rate := 1.0
@export var left_most_col = 1

var enemy_grid_rows = 4
var enemy_grid_cols = 4
var enemy_node_grid: Array[Array] = []

## The Dictionary is `Dictionary[int, bool]` but 'Nested typed collections are not supported.`
##
## key = col, value = row
## this is backwards from normal so I can more easily find the front/back-most cells
var enemy_target_grid: Array[Dictionary] = [{},{},{},{}]

# Using hard coded values because maths is hard :)
var y_position_percentage_offsets = [0.14, 0.32, 0.5, 0.7]

@onready var enemy_status_timer := Timer.new()
@onready var grid: Sprite2D = $"../../../GridContainer/PlayAreaGrid"
@onready var enemy_cell_scene := preload("res://scenes/play_panel/EnemyCell.tscn")

func add_cell_to_target_grid(grid_pos: Vector2):
	enemy_target_grid[grid_pos.y].set(grid_pos.x, true)

func remove_cell_from_target_grid(grid_pos: Vector2):
	enemy_target_grid[grid_pos.y].erase(grid_pos.x)

func _setup_cells():
	# Clear existing children incase they were mistakenly added
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# setup 4x4 grid
	for row in range(enemy_grid_rows):
		enemy_node_grid.push_back([])

		for col in range(enemy_grid_cols):
			var current_cell_scene = enemy_cell_scene.instantiate()
			current_cell_scene.set_grid_pos(Vector2(row, col))
			current_cell_scene.z_index = 0
			
			add_child(current_cell_scene)
			enemy_node_grid[row].push_back(current_cell_scene)

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

func _get_front_target():
	var col_index = 0
	for column in enemy_target_grid:
		if !column.is_empty():
			return enemy_node_grid[column.keys()[randi() % column.size()]][col_index]
		col_index += 1
	
	return false

func _on_resized():
	_position_cells()

# TODO: Make this use a card as a resource
func _on_card_played(card: Dictionary):
	match card["target"]:
		"front":
			var target = _get_front_target()
			if (target):
				target.process_card_effects(card)

func _ready() -> void:
	self.connect("resized", _on_resized)
	SignalBus.card_played_target_enemy.connect(_on_card_played)

	# Gives the game time to process the enemy_scene's size
	await get_tree().process_frame
	_setup_cells()
