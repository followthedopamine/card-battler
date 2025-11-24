extends Enemy

@export var poison: int = 0

func _ready() -> void:
	super()
	var attack := ActionEffect.new()
	attack.damage = damage
	attack.target = ActionEffect.Target.PLAYER

	var poison_attack := ActionEffect.new()
	poison_attack.poison = poison
	poison_attack.target = ActionEffect.Target.PLAYER

	actions = [attack, poison_attack, attack]
