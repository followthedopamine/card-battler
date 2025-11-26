class_name Entity extends Control

@export var max_health: float
@export var block: int:
	get: return block
	set(value):
		block = value
		SignalBus.block_updated.emit(self)

@export var strength: int = 0:
	get: return strength
	set(value):
		strength = value
		SignalBus.strength_updated.emit(self)

var is_slowed := false

@onready var health: float = max_health

@onready var sprite: AnimatedSprite2D  = $Sprite
@onready var damage_particle_emitter: DamageParticleEmitter = $DamageParticleEmitter

func _ready() -> void:
	SignalBus.wave_end.connect(_on_wave_end)
		
func _on_wave_end(_wave: int) -> void:
	block = 0
	strength = 0

func get_sprite_size() -> Vector2:
	var sprite_size = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_size()
	return Vector2(sprite_size.x * sprite.scale.x, sprite_size.y * sprite.scale.y)

func take_damage(damage_taken: float, attacker: Entity = null) -> void:
	if attacker != null:
		damage_taken += attacker.strength
	if block > 0:
		block -= int(damage_taken)
		if block < 0:
			damage_taken = abs(block)
			block = 0
		else: 
			damage_taken = 0
		SignalBus.block_updated.emit(self)
	health -= damage_taken
	SignalBus.damage_taken.emit(self, attacker, damage_taken)

	if damage_taken:
		damage_particle_emitter.emit_particle(str(damage_taken), Color8(201, 0, 62, 220))

func heal(healing: float) -> void:
	if health < max_health:
		health += healing
	if health > max_health:
		health = max_health
	damage_particle_emitter.emit_particle(str(healing), Color8(97, 201, 0, 220))
