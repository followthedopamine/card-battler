extends Card

var original_shield: int

func _ready() -> void:
	original_shield = card_effect.shield
	card_effect.on_play_all_enemy_callables = [effect]
	super()

	
	
func effect(enemies: Array[Enemy]) -> void:
	card_effect.shield = original_shield
	for enemy: Enemy in enemies:
		var poison_status = Status.get_status(enemy, Status.Type.POISON)
		if poison_status == null:
			continue
		card_effect.shield += poison_status.stacks

	# Because of the way callables work the player isn't going to get the shield
	# from the standard card effect
	PlayerManager.player_node.block += card_effect.shield
