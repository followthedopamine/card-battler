class_name ActionEffect
extends Resource

enum Target { NONE, ENEMY, PLAYER, SHOP }
enum GridTarget { NONE, FRONT, BACK, SELF, RANDOM }
enum GridTargetType { NONE, SINGLE, AOE, ALL }
enum Type { ATTACK, STRENGTH_BUFF, HEAL_RANDOM, STRENGTH_BUFF_ALL, POISON_ATTACK, HEAL_ALL }

const ACTION_TYPE_STRING: Dictionary[Type, String] = {
	Type.ATTACK: "attack",
	Type.STRENGTH_BUFF: "strength buff",
	Type.STRENGTH_BUFF_ALL: "strength buff all",
	Type.HEAL_RANDOM: "heal a random ally",
	Type.HEAL_ALL: "heal all allies",
	Type.POISON_ATTACK: "apply poison",
}

var type: Type

# PRIMARY TARGET
@export var target: Target = Target.NONE

# ENEMY TARGETING
@export var enemy_target: GridTarget = GridTarget.NONE
## What is being affected (relative to the target if applicable)
@export var enemy_target_type: GridTargetType  = GridTargetType.NONE

# PLAYER/ENEMY DAMAGE
@export var damage: float
@export var heal: float
@export var strength: int
@export var shield: int

# PLAYER/ENEMY STATUSES
@export var poison: int
@export var bleed: int
@export var stun: int
@export var slow: int
@export var burn: int
@export var thorns: int

@export var on_play_callables: Array[Callable] = []
@export var on_play_enemy_callables: Array[Callable] = []
@export var on_play_all_enemy_callables: Array[Callable] = []
@export var on_kill_callables: Array[Callable] = []
@export var on_next_wave_callable: Array[Callable] = []

func add_on_play_callable(callable: Callable):
	if !callable in on_play_callables:
		on_play_callables.push_front(callable)

func run_on_play_callables():
	for callable in on_play_callables:
		if callable.get_object() != null:
			callable.call()

func run_effects():
	match target:
		Target.ENEMY:
			SignalBus.card_played_target_enemy.emit(self)
		Target.PLAYER:
			SignalBus.card_played_target_player.emit(self)

	if (on_play_callables.size()): 
		run_on_play_callables()
		
func get_intention_string() -> String:
	if ACTION_TYPE_STRING.has(type):
		return ACTION_TYPE_STRING[type]
	return "null"
