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

func _on_enemy_attack(damage: float, enemy: Enemy):
	take_damage(damage, enemy)
	SignalBus.player_health_change.emit(health)
	if health <= 0:
		SignalBus.player_died.emit()

func _on_attack_card_played(_card: Resource):
	is_attacking = true
	
func _on_player_targeted(effect: ActionEffect, enemy: Enemy) -> void:
	if effect.damage:
		take_damage(effect.damage, enemy)
		SignalBus.player_health_change.emit(health)

	if effect.shield:
		block += effect.shield
		
	if effect.thorns:
		Status.new(Status.Type.THORNS, effect.thorns, self)
		
	if effect.heal:
		heal(effect.heal)
		SignalBus.player_health_change.emit(health)
		
	if effect.burn:
		Status.new(Status.Type.BURN, effect.burn, self)

	if effect.poison:
		Status.new(Status.Type.POISON, effect.poison, self)

	if effect.strength:
		strength += effect.strength
		Status.new(Status.Type.STRENGTH, effect.strength, self)

func _ready() -> void:
	super()

	var sprite_size = get_sprite_size()
	damage_particle_emitter.set_emission_box(get_sprite_size())
	damage_particle_emitter.set_emission_offset(Vector2(0, -sprite_size.y * .5))

	SignalBus.player_max_health.emit(max_health)

	SignalBus.player_targeted.connect(_on_player_targeted)
	SignalBus.card_played_target_enemy.connect(_on_attack_card_played)
	SignalBus.card_played_target_player.connect(_on_player_targeted)
	
	PlayerManager.player_node = self

func _physics_process(delta: float) -> void:
	if is_attacking:
		_process_attack_animation(delta)
