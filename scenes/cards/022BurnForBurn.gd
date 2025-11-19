extends Card

func start_card_effect() -> void:
	var enemies: Array[Enemy] = PlayerManager.enemy_area.get_all_enemies()
	for enemy: Enemy in enemies:
		if Status.has_status(enemy, Status.Type.BURN):
			duration = INSTANT_SPEED
			return
