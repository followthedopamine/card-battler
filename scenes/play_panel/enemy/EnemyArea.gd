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

var animation_grid_offset := 0

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

func _position_cells(skip_animation = false):
	# Position grid cells to fit within the drawn grid
	var grid_lines = grid.get_lines()
	var odd_offset = 0.0

	grid_lines.x = grid_lines.x / 2

	var h_offset = odd_offset + left_most_col
	var vertical_slice = size.x / grid_lines.x

	for child: EnemyCell in get_children():
		if (child is EnemyCell):
			child.position_cell(h_offset, y_position_percentage_offsets[child.get_grid_pos().x], vertical_slice, animation_grid_offset, skip_animation)

func _get_target(target: ActionEffect.GridTarget):
	var col_range: Array

	match target:
		ActionEffect.GridTarget.FRONT:
			col_range = range(0, enemy_grid_rows) 
		ActionEffect.GridTarget.BACK:
			col_range = range(enemy_grid_rows - 1, -1, -1)
		ActionEffect.GridTarget.RANDOM:
			col_range = range(0, enemy_grid_rows)
			col_range.shuffle()
		ActionEffect.GridTarget.NONE:
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

	return side_targets

func _get_all_targets() -> Array[EnemyCell]:
	var targets: Array[EnemyCell] = []
	for row in enemy_grid_rows:
		for col in enemy_grid_cols:
			if enemy_cell_grid[row][col].get_has_enemy():
				targets.push_back(enemy_cell_grid[row][col])
	return targets
	
func get_all_enemies() -> Array[Enemy]:
	var targets: Array[EnemyCell] = _get_all_targets()
	var all_enemies: Array[Enemy] = []
	for cell: EnemyCell in targets:
		if cell.has_enemy && is_instance_valid(cell.enemy_scene):
			all_enemies.push_back(cell.enemy_scene)
	return all_enemies
	
func process_all_enemy_callables(card: ActionEffect, all_enemies: Array[Enemy]) -> void:
	for callable: Callable in card.on_play_all_enemy_callables:
		# Hopefully fixes a crash where the callable can sometimes be null?
		if callable.get_object() == null:
			print("ERROR (process_all_enemy_callables): '%s' Callable was null and would have crashed here" % callable.get_method())
			continue
		callable.call(all_enemies)

func _on_any_card_played(_card: Card) -> void:
	if Status.has_status(PlayerManager.player_node, Status.Type.FUSE):
		var status: Status = Status.get_status(PlayerManager.player_node, Status.Type.FUSE)
	
		if status.stacks == 0:
			var temp_card_effect: CardEffect = CardEffect.new()
			temp_card_effect.damage = LightFuse.EXPLOSION_DAMAGE
			var all_cells: Array[EnemyCell] = _get_all_targets()

			for target in all_cells:
				target.process_action_effects(temp_card_effect)

func _on_enemy_targeted(action: ActionEffect):
	if action.on_play_all_enemy_callables.size():
		var all_enemies: Array[Enemy] = get_all_enemies()
		process_all_enemy_callables(action, all_enemies)
	
	# GridTargetType.ALL can skip checking for a grid_target
	if action.enemy_target_type == action.GridTargetType.ALL:
		var all_cells: Array[EnemyCell] = _get_all_targets()
		for target in all_cells:
			target.process_action_effects(action)
	else:
		var grid_target = _get_target(action.enemy_target)
		if (grid_target):
			match action.enemy_target_type:
				action.GridTargetType.SINGLE:
					grid_target.process_action_effects(action)			
				action.GridTargetType.AOE:
					var aoe_targets = _get_aoe_targets(grid_target)
					for target in aoe_targets:
						target.process_action_effects(action)
			

func _on_resized():
	_position_cells(true)

func _on_animation_grid_offset(offset: int):
	animation_grid_offset = offset

func _ready() -> void:
	self.connect("resized", _on_resized)
	## non-card effects that target enemies
	SignalBus.enemy_targeted.connect(_on_enemy_targeted)

	SignalBus.card_played_target_enemy.connect(_on_enemy_targeted)
	SignalBus.card_played.connect(_on_any_card_played)
	SignalBus.animation_grid_offset.connect(_on_animation_grid_offset)

	# Gives the game time to process the enemy_scene's size
	await get_tree().process_frame
	_setup_cells()
	
	is_setup = true
	SignalBus.enemy_area_setup.emit()
	PlayerManager.enemy_area = self
