extends Enemy

@export var strength_buff: int = 3
@export var slow_duration: int = 3
@export var poison_amount: int = 3
@export var burn_amount: int = 3

var stage = 0

func _ready() -> void:
	super()
	actions = actions_set_base()
	
func actions_set_base() -> Array[ActionEffect]:
	var attack := ActionEffect.new()
	attack.type = ActionEffect.Type.ATTACK
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var buff_1 := ActionEffect.new()
	buff_1.type = ActionEffect.Type.STRENGTH_BUFF
	buff_1.strength = strength_buff
	buff_1.target = ActionEffect.Target.ENEMY
	buff_1.enemy_target = ActionEffect.GridTarget.SELF
	buff_1.enemy_target_type = ActionEffect.GridTargetType.SINGLE

	var slow_player := ActionEffect.new()
	slow_player.slow = slow_duration
	slow_player.target = ActionEffect.Target.PLAYER

	var current_actions: Array[ActionEffect] = [attack, buff_1, slow_player]
	current_actions.shuffle()

	return current_actions

func actions_set_poison() -> Array[ActionEffect]:
	var poison := ActionEffect.new()
	poison.type = ActionEffect.Type.POISON_ATTACK
	poison.poison = poison_amount
	poison.target = ActionEffect.Target.PLAYER

	return [poison]

func actions_set_burn() -> Array[ActionEffect]:
	var burn := ActionEffect.new()
	burn.type = ActionEffect.Type.BURN_ATTACK
	burn.burn = burn_amount
	burn.target = ActionEffect.Target.PLAYER

	return [burn]

func actions_set_finale():
	var combined_actions := actions_set_base() + actions_set_poison() + actions_set_burn()
	combined_actions.shuffle()
	return combined_actions

func _process(_delta: float) -> void:
	if stage == 0 && health < (max_health * .75):
		stage = 1
		current_action = 0
		actions = actions_set_poison()
	elif stage == 1 && health < (max_health * .5):
		stage = 2
		current_action = 0
		actions = actions_set_burn()
	elif stage == 2 && health < (max_health * .25):
		stage = 3
		current_action = 0
		action_speed = 0.5
		actions = actions_set_finale()
