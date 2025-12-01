extends Relic

func added_effect() -> void:
	SignalBus.block_updated.connect(_on_block_updated)
	PlayerManager.player_node.max_health += PlayerManager.player_node.max_health
	
func _on_block_updated(entity: Entity) -> void:
	if entity.block == 0:
		return
	if entity is Player:
		entity.heal(entity.block)
		entity.block = 0
