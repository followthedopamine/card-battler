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
			enemy_scene.take_damage(card.damage, PlayerManager.player_node)
			handle_extra_player_attacks(card)
			
		if card.burn:
			Status.new(Status.Type.BURN, card.burn, enemy_scene)
			
		if card.slow:
			Status.new(Status.Type.SLOW, card.slow, enemy_scene)
			
		if card.poison:
			Status.new(Status.Type.POISON, card.poison, enemy_scene)
		

## So the enemy can report that it has been removed/defeated/whatever
func enemy_cleared():
	has_enemy = false
	parent.clear_enemy_from_grid(grid_pos)
	
func handle_extra_player_attacks(card: CardEffect) -> void:
	var status: Status = Status.get_status(PlayerManager.player_node, Status.Type.EXTRA_ATTACK)
	if status != null:
		if status.stacks > 0:
			Status.new(Status.Type.EXTRA_ATTACK, -1, PlayerManager.player_node)
			process_card_effects(card)

func _ready() -> void:
	self.mouse_filter = Control.MouseFilter.MOUSE_FILTER_IGNORE
