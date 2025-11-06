extends Control

@export var enemy_scene : PackedScene
@export var enemy_status_tick_rate := 1.0
@export var left_most_col = 1


var enemy_grid_rows = 4
var enemy_grid_cols = 4

# Using hard coded values because maths is hard :)
var y_position_percentage_offsets = [0.14, 0.32, 0.5, 0.7]

@onready var enemy_status_timer := Timer.new()
@onready var grid: Sprite2D = $"../../../GridContainer/PlayAreaGrid"

func setup_enemies():
	# Clear existing children incase they were mistakenly added
	for child in get_children():
		remove_child(child)
		child.queue_free()

	# setup 4x4 grid
	for row in range(enemy_grid_rows):
		for col in range(enemy_grid_cols):
			var current_enemy_scene = enemy_scene.instantiate()
			current_enemy_scene.set_grid_pos(Vector2(row, col))
			current_enemy_scene.z_index = 200
			add_child(current_enemy_scene)

	position_enemies()

func position_enemy(enemy_node: Node2D, grid_position: Vector2, h_offset: float, vertical_slice: float):
	enemy_node.set_position(Vector2(
		(h_offset + grid_position.y) * (vertical_slice + (vertical_slice * y_position_percentage_offsets[grid_position.x])),
		size.y * y_position_percentage_offsets[grid_position.x])
	)

func position_enemies():
	# setup grid handling
	var grid_lines = grid.get_lines()
	var odd_offset = 0.0

	grid_lines.x = grid_lines.x / 2

	var h_offset = odd_offset + left_most_col
	var vertical_slice = size.x / grid_lines.x	

	for child in get_children():
		if (child.is_in_group("Enemy")):
			position_enemy(child, child.get_grid_pos(), h_offset, vertical_slice)

func _on_enemy_status_timer_timeout():
	print("owie")

func _on_resized():
	position_enemies()


func _ready() -> void:
	self.connect("resized", _on_resized)

	add_child(enemy_status_timer)
	enemy_status_timer.wait_time = enemy_status_tick_rate
	enemy_status_timer.one_shot = false
	enemy_status_timer.timeout.connect(_on_enemy_status_timer_timeout)
	enemy_status_timer.start()

	# Gives the game time to process the enemy_scene's size
	await get_tree().process_frame
	setup_enemies()
