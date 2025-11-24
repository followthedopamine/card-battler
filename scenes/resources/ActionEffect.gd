class_name ActionEffect
extends Resource

enum Target { NONE, ENEMY, PLAYER, SHOP }
enum GridTarget { NONE, FRONT, BACK, SELF, RANDOM }
enum GridTargetType { NONE, SINGLE, AOE, ALL }

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
