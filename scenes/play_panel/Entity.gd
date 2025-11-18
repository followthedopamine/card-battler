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

@onready var health: float = max_health


func _ready() -> void:
	SignalBus.wave_end.connect(_on_wave_end)
		
func _on_wave_end(_wave: int) -> void:
	block = 0
	strength = 0

func take_damage(damage_taken: float, attacker: Entity = null) -> void:
	if attacker != null:
		damage_taken += attacker.strength
	if block > 0:
		block -= damage_taken
		if block < 0:
			damage_taken = abs(block)
			block = 0
		else: 
			damage_taken = 0
		SignalBus.block_updated.emit(self)
	health -= damage_taken
	SignalBus.damage_taken.emit(self, attacker)
	
func heal(healing: float) -> void:
	if health < max_health:
		health += healing
	if health > max_health:
		health = max_health
	
