class_name CardEffect
extends Resource

enum Target { NONE, ENEMY, PLAYER, SHOP }
enum GridTarget { NONE, FRONT, BACK, RANDOM }
enum GridTargetType { NONE, SINGLE, AOE, ALL }

# PRIMARY CARD TARGET
@export var target: Target

# ENEMY TARGETING
@export var enemy_target: GridTarget
## What is being affected (relative to the target if applicable)
@export var enemy_target_type: GridTargetType 

# PLAYER/ENEMY DAMAGE
@export var damage: float

# PLAYER/ENEMY STATUSES
@export var poison: int
@export var bleed: int
@export var stun: int
@export var slow: int
@export var burn: int
@export var thorns: int

# PLAYER DEFENSIVE
@export var shield: float
@export var heal: float

## ECONOMY 
## Coins given or taken on playing the card
@export var currency: int

@export var on_play_callables: Array[Callable] = []

func add_on_play_callable(callable: Callable):
	on_play_callables.push_front(callable)

func run_on_play_callables():
	for callable in on_play_callables:
		callable.call()

func modify_currency(coin_amount: int):
	var modified_currency = floori(coin_amount * PlayerManager.currency_modifier)
	PlayerManager.currency += modified_currency

func run_effects():
	match target:
		Target.ENEMY:
			SignalBus.card_played_target_enemy.emit(self)
		Target.PLAYER:
			SignalBus.card_played_target_player.emit(self)
		Target.SHOP:
			SignalBus.card_played_target_shop.emit(self)
	
	if (currency): 
		modify_currency(currency)

	if (on_play_callables.size()): 
		run_on_play_callables()
