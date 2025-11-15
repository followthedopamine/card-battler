class_name Enemy extends Entity

@export var spawn_value = 1

## What wave this enemy starts spawning on
@export var first_available_wave = 1

@export var damage: float = 0.5
@export var attack_speed: float = 1.5
@export var spawn_columns: Array[int] = [0, 1, 2, 3]

#health = float(max_health)

# Statuses
var poison = 0
var bleed = 0
var burning = 0
#var block: float = 0.0

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
@onready var sprite: AnimatedSprite2D  = $Sprite
@onready var parent = get_parent()

@onready var attack_timer := Timer.new()

func attack():
	SignalBus.enemy_attack.emit(damage)
	is_attacking = true

func take_damage(damage_taken: float):
	super(damage_taken)
	health_bar.set_health(health)
	health_bar.visible = true

	show_damage_taken_health_bar = true
	damage_taken_health_bar_elapsed = 0.0

	if health <= 0:
		die()

func get_sprite_size() -> Vector2:
	var sprite_size = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_size()
	return Vector2(sprite_size.x * sprite.scale.x, sprite_size.y * sprite.scale.y)

func die():
	health = 0

	if parent.has_method("enemy_cleared"):
		parent.enemy_cleared()

	queue_free()

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
	health_bar.set_max_health(max_health)

	# Get the sprite sizes to base the healthbar's position off of
	var sprite_size = get_sprite_size()

	# Set the size of the healthbar
	health_bar.size.x = sprite_size.x
	health_bar.size.y = max(floor(sprite_size.x / 16), 4)

	# Set the position of the healthbar
	health_bar.position.y -= health_bar.size.y * 1.5

func _on_attack_timer_timeout():
	attack()

func _on_mouse_entered():
	health_bar.visible = true
	show_mouse_over_health_bar = true

func _on_mouse_exited():
	show_mouse_over_health_bar = false

func _ready() -> void:
	super()
	health = max_health

	var sprite_size = get_sprite_size()
	var parent_size = get_parent().size
	size = sprite_size
	position = (parent_size * 0.5) - (size * 0.5)
	
	# TODO: .25 kinda works but I can't see why it doesn't position based on half the sprite's size
	position.y -= sprite_size.y * 0.25

	sprite.centered = false

	_setup_health_bar()

	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)

	add_child(attack_timer)
	attack_timer.wait_time = attack_speed
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()

func _physics_process(delta: float) -> void:
	if is_attacking:
		_process_attack_animation(delta)
	
	if (show_damage_taken_health_bar):
		damage_taken_health_bar_elapsed += delta

		if (damage_taken_health_bar_elapsed >= damage_taken_health_bar_duration):
			show_damage_taken_health_bar = false

	if !show_mouse_over_health_bar && !show_damage_taken_health_bar:
		health_bar.visible = false
