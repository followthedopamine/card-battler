extends Card

var original_shield: int

func _ready() -> void:
	original_shield = card_effect.shield
	card_effect.on_play_all_enemy_callables = [effect]
	super()

	
func effect(enemies: Array[Enemy]) -> void:
	var shield_to_add: int = 0
	for enemy: Enemy in enemies:
		var poison_status = Status.get_status(enemy, Status.Type.POISON)
		if poison_status == null:
			continue
		shield_to_add += poison_status.stacks

	# Because of the way callables work the player isn't going to get the shield
	# from the standard card effect
	PlayerManager.player_node.block += shield_to_add
	SignalBus.player_added_block.emit()
