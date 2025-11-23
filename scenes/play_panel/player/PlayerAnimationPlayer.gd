extends AnimationPlayer

@export var smoke_particles: GPUParticles2D
@export var blood_particles: GPUParticles2D

@onready var parent = get_parent()

func _ready() -> void:
	SignalBus.damage_taken.connect(_on_damage_taken)
	SignalBus.card_played_target_enemy.connect(_on_card_played_target_enemy)
	SignalBus.wave_end.connect(_on_wave_end)
	SignalBus.animation_end.connect(_on_animation_end)
	self.play("wave_transition")
	
func _on_damage_taken(target: Entity, _attacker: Entity) -> void:
	if target == parent:
		blood_particles.emitting = true
		if !is_playing():
			self.play("RESET")
			self.play("hit")

func _on_card_played_target_enemy(_card: CardEffect) -> void:
	self.play("RESET")
	self.play("attack", 0.1)

func _on_wave_end(_wave: int) -> void:
	smoke_particles.emitting = true
	self.play("RESET")
	self.play("wave_transition", 0.1)
	
func _on_animation_end() -> void:
	smoke_particles.emitting = false
