extends Enemy

@export var poison: int = 0

func _ready() -> void:
	super()
	var attack := ActionEffect.new()
	attack.type = ActionEffect.Type.ATTACK
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var poison_attack := ActionEffect.new()
	poison_attack.type = ActionEffect.Type.POISON_ATTACK
	poison_attack.poison = poison
	poison_attack.target = ActionEffect.Target.PLAYER

	actions = [attack, poison_attack, attack]
	set_tooltips()
