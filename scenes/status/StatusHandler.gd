class_name StatusHandler extends Control

const BURN_DURATION: float = 2.0
const SLOW_ADDITION: float = 1.0

@export var status_bar: StatusBar

@onready var parent = get_parent()

var current_statuses: Array[Status]

func _ready() -> void:
	SignalBus.status_updated.connect(_on_status_updated)
	SignalBus.block_updated.connect(_on_block_updated)
	SignalBus.damage_taken.connect(_on_damage_taken)
	SignalBus.wave_end.connect(_on_wave_end)
	
func _on_status_updated(status: Status, node: Node) -> void:
	if node != parent:
		return
	var current_status = get_current_status(status.effect)
	if current_status == null:
		add_status(status)
		return
	current_status.stacks += status.stacks
	if current_status.effect == Status.Type.SLOW:
		add_slow()
		
func _on_wave_end(_wave: int) -> void:
	current_statuses = []

func _on_block_updated(node: Node) -> void:
	if node == parent:
		var status = get_current_status(Status.Type.BLOCK)
		if status == null:
			status = Status.new()
			status.effect = Status.Type.BLOCK
			status.stacks = node.block
			add_status(status)
			
func _on_strength_updated(entity: Entity) -> void:
	if entity == parent:
		var status = get_current_status(Status.Type.STRENGTH)
		if status == null:
			status = Status.new()
			status.effect = Status.Type.STRENGTH
			status.stacks = entity.strength
			add_status(status)

func _on_damage_taken(target: Entity, attacker: Entity) -> void:
	if attacker == null:
		return
	if target != parent:
		return
	var thorns: Status = get_current_status(Status.Type.THORNS)
	if thorns == null:
		return
	attacker.take_damage(thorns.stacks)

func _on_burn_timer_timeout() -> void:
	var burn = get_current_status(Status.Type.BURN)
	if burn != null:
		if parent is Entity:
			parent.take_damage(burn.stacks)
	
func get_current_status(status_type: Status.Type) -> Status:
	for current_status: Status in current_statuses:
		if current_status.effect == status_type:
			return current_status
	return null
	
func start_burn() -> void:
	var timer: Timer = Timer.new()
	self.add_child(timer)
	timer.start(BURN_DURATION)
	timer.timeout.connect(_on_burn_timer_timeout)
	
func add_slow() -> void:
	if parent is Enemy:
		parent.attack_timer.wait_time += SLOW_ADDITION
	
func add_status(status: Status) -> void:
	if status.effect == Status.Type.BURN:
		start_burn()
		
	if status.effect == Status.Type.SLOW:
		add_slow()
	
	
		
	current_statuses.append(status)
