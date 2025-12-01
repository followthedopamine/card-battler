extends Enemy

@export var shield_amount: int = 5
@export var strength_amount: int = 1

func _ready() -> void:
	super()

	var attack := ActionEffect.new()
	attack.type = ActionEffect.Type.ATTACK
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var shield := ActionEffect.new()
	shield.type = ActionEffect.Type.BLOCK_BUFF
	shield.shield = shield_amount
	shield.shield = strength_amount
	shield.target = ActionEffect.Target.ENEMY
	shield.enemy_target = ActionEffect.GridTarget.SELF

	actions = [shield, attack]
	set_tooltips()
