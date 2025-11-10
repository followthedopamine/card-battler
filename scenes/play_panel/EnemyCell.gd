extends Control

var grid_pos: Vector2
var parent_position_percentage: Vector2 

var has_enemy := false
var enemy_scene:Node

@onready var enemy_packed_scene := preload("res://scenes/play_panel/Enemy.tscn")

## Expected to be EnemyArea
@onready var parent := get_parent()

func get_grid_pos():
	return grid_pos

func set_grid_pos(pos: Vector2):
	grid_pos = pos

func spawn_enemy():
	for child in get_children():
		if (child.is_in_group("Enemy")):
			# Intentional debug message as there shouldn't be children here.
			print("Unexpected enemy found at" ,grid_pos , ":", child.name, ". Deleting Enemy node.")
			remove_child(child)
			child.queue_free()
	
	# TODO: actual enemy generation:
	if randi() > 0.5:
		enemy_scene = enemy_packed_scene.instantiate()
		add_child(enemy_scene)
		has_enemy = true
		parent.add_cell_to_target_grid(grid_pos)

func process_card_effects(card: Dictionary):
	if has_enemy && is_instance_valid(enemy_scene):
		if card["damage"]:
			enemy_scene.take_damage(card["damage"])
		

## So the enemy can report that it has been removed/defeated/whatever
func enemy_cleared():
	has_enemy = false
	parent.remove_cell_from_target_grid(grid_pos)

func _ready() -> void:
	self.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
	spawn_enemy()
