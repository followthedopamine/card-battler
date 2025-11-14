class_name EnemyCell extends Control

var grid_pos: Vector2
var parent_position_percentage: Vector2 

var has_enemy := false
var enemy_scene: Enemy

# @onready var enemy_packed_scene := preload("res://scenes/play_panel/Enemy.tscn")

## Expected to be EnemyArea
@onready var parent := get_parent()

func get_has_enemy():
	return has_enemy

func get_grid_pos():
	return grid_pos

func set_grid_pos(pos: Vector2):
	grid_pos = pos

func spawn_enemy(enemy: Enemy):
	for child in get_children():
		if (child.is_in_group("Enemy")):
			# Intentional debug message as there shouldn't be children here.
			print("Unexpected enemy found at: " ,grid_pos , ":", child.name, ". Deleting Enemy node.")
			remove_child(child)
			child.queue_free()
	

	has_enemy = true
	enemy_scene = enemy
	add_child(enemy_scene)
	parent.add_cell_to_target_grid(grid_pos)

func process_card_effects(card: CardEffect):
	if has_enemy && is_instance_valid(enemy_scene):
		if card.damage:
			enemy_scene.take_damage(card.damage)
			
		if card.poison:
			var status: Status = Status.new()
			status.effect = Status.Type.BURN
			status.stacks = card.poison
			SignalBus.status_updated.emit(status, enemy_scene)
		

## So the enemy can report that it has been removed/defeated/whatever
func enemy_cleared():
	has_enemy = false
	parent.clear_enemy_from_grid(grid_pos)

func _ready() -> void:
	self.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
