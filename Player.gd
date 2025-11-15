class_name Player extends Entity

#@export var max_health = 100
#
#var health = max_health

# attack animation variables
## In px
var x_attack_offset := 60
## In Seconds
var attack_duration := .5

var is_attacking := false
## In Seconds
var attack_elapsed := 0.0
var attack_direction := 1

@onready var sprite: AnimatedSprite2D  = $Sprite

func _process_attack_animation(delta: float):
	# how much of the attack duration is processed in this instance of the function
	var tick_fraction = delta/attack_duration

	attack_elapsed += tick_fraction
	sprite.offset.x += attack_direction * x_attack_offset * tick_fraction * 2

	# reverse the movement direct at the half way point
	if attack_direction > 0 && attack_elapsed > 0.5 * attack_duration:
		attack_direction = -1

	# Return everything to normal after the animation is complete
	elif attack_elapsed > attack_duration:
		is_attacking = false
		attack_elapsed = 0
		sprite.offset.x = 0
		attack_direction = 1

func _on_enemy_attack(damage: float):
	take_damage(damage)
	SignalBus.player_health_change.emit(health)

func _on_attack_card_played(_card: Resource):
	is_attacking = true
	
func _on_player_targeted(card_effect: CardEffect) -> void:
	if card_effect.shield:
		block += card_effect.shield

func _ready() -> void:
	super()
	SignalBus.player_max_health.emit(max_health)

	SignalBus.enemy_attack.connect(_on_enemy_attack)
	SignalBus.card_played_target_enemy.connect(_on_attack_card_played)
	SignalBus.card_played_target_player.connect(_on_player_targeted)

func _physics_process(delta: float) -> void:
	if is_attacking:
		_process_attack_animation(delta)
