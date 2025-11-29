extends AnimationPlayer


@onready var parent = get_parent()

func _ready() -> void:
	SignalBus.damage_taken.connect(_on_damage_taken)
	SignalBus.player_targeted.connect(_on_player_targeted)
	
func _on_damage_taken(target: Entity, _attacker: Entity, damage: float) -> void:
	if target == parent:
		if damage > 0:
			if is_playing():
				return
			play("hit", 0.1)

func _on_player_targeted(effect: ActionEffect, source: Enemy) -> void:
	if source == parent:
		if effect.damage:
			play("attack", 0.1)
