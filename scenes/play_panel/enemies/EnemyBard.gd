extends Enemy

@export var healing: float = 0.0
@export var strength_buff: int = 0

func _ready() -> void:
	super()
	var action1 := ActionEffect.new()
	action1.type = ActionEffect.Type.HEAL_RANDOM
	action1.heal = healing
	action1.target = ActionEffect.Target.ENEMY
	action1.enemy_target = ActionEffect.GridTarget.RANDOM
	action1.enemy_target_type = ActionEffect.GridTargetType.AOE

	var action2 := ActionEffect.new()
	action2.type = ActionEffect.Type.STRENGTH_BUFF_ALL
	action2.strength = strength_buff
	action2.target = ActionEffect.Target.ENEMY
	action2.enemy_target = ActionEffect.GridTarget.NONE
	action2.enemy_target_type = ActionEffect.GridTargetType.ALL

	var action3 := ActionEffect.new()
	action3.type = ActionEffect.Type.ATTACK
	action3.damage = damage
	action3.target = ActionEffect.Target.PLAYER

	actions = [action1, action2, action3]
	set_tooltips()
