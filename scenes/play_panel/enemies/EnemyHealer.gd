extends Enemy

@export var healing: float = 5.0

func _ready() -> void:
	super()
	var action1 := ActionEffect.new()
	action1.type = ActionEffect.Type.HEAL_ALL
	action1.heal = healing
	action1.target = ActionEffect.Target.ENEMY
	action1.enemy_target_type = ActionEffect.GridTargetType.ALL

	actions = [action1]
	set_tooltips()
