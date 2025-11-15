class_name Entity extends Control

@export var max_health: float
@export var block: float:
	get: return block
	set(value):
		block = value
		SignalBus.block_updated.emit(self)

@onready var health: float = max_health

func _ready() -> void:
	SignalBus.wave_end.connect(_on_wave_end)
		
func _on_wave_end(_wave: int) -> void:
	if block > 0:
		block = 0

func take_damage(damage_taken: float):
	if block > 0:
		block -= damage_taken
		if block < 0:
			damage_taken = abs(block)
			block = 0
		else: 
			damage_taken = 0
		SignalBus.block_updated.emit(self)
	health -= damage_taken
	
