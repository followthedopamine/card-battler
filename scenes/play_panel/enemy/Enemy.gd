class_name Enemy extends Entity

@export var enemy_name = ""

@export var spawn_value = 1

## What wave this enemy starts spawning on
@export var first_available_wave = 1

@export var damage: float = 0.5

@export var action_speed: float = 1.5
@export var spawn_columns: Array[int] = [0, 1, 2, 3]

var actions: Array[ActionEffect] = []
var current_action = 0
var current_action_speed := 0.0
var action_time_remaining := 0.0

# attack animation variables
## In px
var x_attack_offset := 60
## In seconds
var attack_duration := .5

var is_attacking := false
var attack_elapsed := 0.0
var attack_direction := -1

# Handling for displaying the healthbar after taking damage or mousing over
var show_mouse_over_health_bar := false
var show_damage_taken_health_bar := false
var damage_taken_health_bar_duration := 1
var damage_taken_health_bar_elapsed := 0.0

@onready var health_bar: HealthBar = $HealthBar
@onready var parent = get_parent()

@onready var action_timer := Timer.new()

func deal_damage(action: ActionEffect):
	SignalBus.player_targeted.emit(action, self)
	is_attacking = true

func take_damage(damage_taken: float, attacker: Entity = null):
	super(damage_taken, attacker)
	health_bar.set_health(int(health))
	health_bar.visible = true

	show_damage_taken_health_bar = true
	damage_taken_health_bar_elapsed = 0.0

	if health <= 0:
		die()

func heal(healing_amount: float):
	super(healing_amount)
	health_bar.set_health(int(health))
	health_bar.visible = true

	show_damage_taken_health_bar = true
	damage_taken_health_bar_elapsed = 0.0

func get_sprite_size() -> Vector2:
	var sprite_size = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_size()
	return Vector2(sprite_size.x * sprite.scale.x, sprite_size.y * sprite.scale.y)

func die():
	health = 0

	if parent.has_method("enemy_cleared"):
		parent.enemy_cleared()
	
	process_on_kill_callables()
	
	queue_free()
	
func process_on_kill_callables() -> void:
	var last_card = PlayerManager.last_card_activated
	if last_card == null:
		return
	var callables: Array[Callable] = last_card.card_effect.on_kill_callables
	if !callables.size():
		return
	for callable: Callable in callables:
		callable.call()

func _process_attack_animation(delta: float):
	# how much of the attack duration is processed in this instance of the function
	var tick_fraction = delta/attack_duration

	attack_elapsed += tick_fraction
	sprite.offset.x += attack_direction * x_attack_offset * tick_fraction * 2

	# reverse the movement direct at the half way point
	if attack_direction < 0 && attack_elapsed > 0.5 * attack_duration:
		attack_direction = 1

	# Return everything to normal after the animation is complete
	elif attack_elapsed > attack_duration:
		is_attacking = false
		attack_elapsed = 0
		sprite.offset.x = 0
		attack_direction = -1

func _setup_health_bar():
	health_bar.set_max_health(int(max_health))

	# Get the sprite sizes to base the healthbar's position off of
	var sprite_size = get_sprite_size()

	# Set the size of the healthbar
	health_bar.size.x = sprite_size.x
	health_bar.size.y = max(floor(sprite_size.x / 16), 4)

	# Set the position of the healthbar
	health_bar.position.y -= health_bar.size.y * 1.5

func process_next_action():
	if !actions.size():
		print("Enemy %s has no actions attached. It will not act." % enemy_name)
		return
		
	var action := actions[current_action]
	current_action = (current_action + 1) % actions.size()

	if action.target == ActionEffect.Target.PLAYER:
		deal_damage(action)

	if action.target == ActionEffect.Target.ENEMY:
		if action.enemy_target == ActionEffect.GridTarget.SELF:
			if parent.has_method("process_action_effects"):
				parent.process_action_effects(action)
		else:
			SignalBus.enemy_targeted.emit(action)

	start_next_action()

func _on_mouse_entered():
	health_bar.visible = true
	show_mouse_over_health_bar = true

func _on_mouse_exited():
	show_mouse_over_health_bar = false
	
func start_next_action():
	current_action_speed = randf_range(action_speed*.9, action_speed*1.1)
	action_time_remaining = current_action_speed

func _on_wave_start_animation_end():
	start_next_action()

func _ready() -> void:
	super()

	# Placeholder action
	var action1 := ActionEffect.new()
	action1.damage = damage
	action1.target = ActionEffect.Target.PLAYER
	actions = [action1]

	health = max_health

	var sprite_size = get_sprite_size()
	var parent_size = get_parent().size
	size = sprite_size
	position = (parent_size * 0.5) - (size * 0.5)
	
	# TODO: .25 kinda works but I can't see why it doesn't position based on half the sprite's size
	position.y -= sprite_size.y * 0.25

	sprite.centered = false

	_setup_health_bar()
	damage_particle_emitter.set_emission_box(sprite_size)
	damage_particle_emitter.set_emission_offset(Vector2(sprite_size.x * .5, 0))

	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	SignalBus.animation_end.connect(_on_wave_start_animation_end)

func _physics_process(delta: float) -> void:
	if is_attacking:
		_process_attack_animation(delta)
	
	if (show_damage_taken_health_bar):
		damage_taken_health_bar_elapsed += delta

		if (damage_taken_health_bar_elapsed >= damage_taken_health_bar_duration):
			show_damage_taken_health_bar = false

	if !show_mouse_over_health_bar && !show_damage_taken_health_bar:
		health_bar.visible = false
	
	if action_time_remaining:
		var delta_timer = delta if !is_slowed else delta * 0.5
		action_time_remaining -= delta_timer
		
		if action_time_remaining <= 0:
			process_next_action()
