extends Enemy

@export var strength_buff: int = 5

func _ready() -> void:
	super()

	var attack := ActionEffect.new()
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var buff_self := ActionEffect.new()
	buff_self.strength = strength_buff
	buff_self.target = ActionEffect.Target.ENEMY
	buff_self.enemy_target = ActionEffect.GridTarget.SELF

	actions = [buff_self, buff_self, attack]