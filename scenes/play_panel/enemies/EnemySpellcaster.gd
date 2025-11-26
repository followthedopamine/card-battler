extends Enemy

@export var strength_buff: int = 1

func _ready() -> void:
	super()

	var attack := ActionEffect.new()
	attack.type = ActionEffect.Type.ATTACK
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var buff_self := ActionEffect.new()
	buff_self.type = ActionEffect.Type.STRENGTH_BUFF
	buff_self.strength = strength_buff
	buff_self.target = ActionEffect.Target.ENEMY
	buff_self.enemy_target = ActionEffect.GridTarget.SELF

	actions = [attack, buff_self]
	
	set_tooltips()
	
