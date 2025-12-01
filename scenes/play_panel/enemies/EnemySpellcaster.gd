extends Enemy

@export var strength_buff: int = 3
@export var slow_duration: int = 1
@export var shield_amount: int = 3

func _ready() -> void:
	super()

	var attack := ActionEffect.new()
	attack.type = ActionEffect.Type.ATTACK
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var buff_random := ActionEffect.new()
	buff_random.type = ActionEffect.Type.STRENGTH_BUFF_AOE
	buff_random.strength = strength_buff
	buff_random.target = ActionEffect.Target.ENEMY
	buff_random.enemy_target = ActionEffect.GridTarget.RANDOM
	buff_random.enemy_target_type = ActionEffect.GridTargetType.AOE

	var shield_random := ActionEffect.new()
	shield_random.type = ActionEffect.Type.BLOCK
	shield_random.shield = shield_amount
	shield_random.target = ActionEffect.Target.ENEMY
	shield_random.enemy_target = ActionEffect.GridTarget.RANDOM
	shield_random.enemy_target_type = ActionEffect.GridTargetType.AOE

	var slow_player := ActionEffect.new()
	slow_player.slow = slow_duration
	slow_player.target = ActionEffect.Target.PLAYER

	actions = [attack, buff_random, shield_random, slow_player]
	actions.shuffle()
