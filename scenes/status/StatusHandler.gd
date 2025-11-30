class_name StatusHandler extends Control

const BURN_DURATION: float = 0.5
const POISON_DURATION: float = 2.0
const SLOW_DURATION: float = 1.0

@export var status_bar: StatusBar

@onready var parent = get_parent()

var current_statuses: Array[Status]

var burn_timer: Timer = Timer.new()
var poison_timer: Timer = Timer.new()
var slow_timer: Timer = Timer.new()

func _ready() -> void:
	SignalBus.status_updated.connect(_on_status_updated)
	SignalBus.block_updated.connect(_on_block_updated)
	SignalBus.damage_taken.connect(_on_damage_taken)
	SignalBus.wave_end.connect(_on_wave_end)
	SignalBus.card_played.connect(_on_card_played)
	self.add_child(burn_timer)
	self.add_child(poison_timer)
	self.add_child(slow_timer)
	
func _on_status_updated(status: Status, node: Node) -> void:
	if node != parent:
		return

	var current_status = get_current_status(status.effect)
	if current_status == null:
		add_status(status)
		return
		
	# If the total stacks are being changed
	if status.stacks:
		if status.stacks && !current_status.stacks:
			if current_status.effect == Status.Type.BURN:
				burn_timer.start(BURN_DURATION)
			if current_status.effect == Status.Type.POISON:
				poison_timer.start(POISON_DURATION)
			if current_status.effect == Status.Type.SLOW:
				slow_timer.start(SLOW_DURATION)
			if current_status.effect == Status.Type.FUSE:
				return
		current_status.stacks += status.stacks

	# If no stacks are being added and no current stacks then remove the timer
	elif !current_status.stacks:
		if current_status.effect == Status.Type.BURN:
			burn_timer.stop()
		if current_status.effect == Status.Type.POISON:
			burn_timer.stop()
		if current_status.effect == Status.Type.SLOW:
			slow_timer.stop()
		
func _on_card_played(card: Card) -> void:
	handle_fuse()
	var status: Status = Status.get_status(PlayerManager.player_node, Status.Type.EXTRA_ATTACK)
	if status != null && status.stacks > 0:
		Status.new(Status.Type.EXTRA_ATTACK, -1, PlayerManager.player_node)
		# Currently this will use all the extra stacks at once
		card.activate_card_effect()
		
func _on_wave_end(_wave: int) -> void:
	for status: Status in current_statuses:
		status.stacks = 0
		if status.effect == Status.Type.FUSE:
			status.stacks = -1
	#current_statuses = []

func _on_block_updated(node: Node) -> void:
	if node == parent:
		if node.block == 0:
			return
		var status = get_current_status(Status.Type.BLOCK)
		if status == null:
			status = Status.new(Status.Type.BLOCK, node.block, node, false)
			add_status(status)
			
func _on_strength_updated(entity: Entity) -> void:
	if entity == parent:
		var status = get_current_status(Status.Type.STRENGTH)
		if status == null:
			status = Status.new(Status.Type.STRENGTH, entity.strength, entity, false)
			add_status(status)

func _on_damage_taken(target: Entity, attacker: Entity, _damage: float) -> void:
	if attacker == null:
		return
	
	handle_thorns(target, attacker)

func _on_burn_timer_timeout() -> void:
	var burn = get_current_status(Status.Type.BURN)
	if burn != null:
		if parent is Entity:
			parent.take_damage(burn.stacks)
			if burn.stacks > 0:
				burn.stacks -= 1
				SignalBus.status_refreshed.emit(burn, parent)
			
func _on_poison_timer_timeout() -> void:
	var poison = get_current_status(Status.Type.POISON)
	if poison != null:
		if parent is Entity:
			parent.take_damage(poison.stacks)

func _on_slow_timer_timeout() -> void:
	var slow = get_current_status(Status.Type.SLOW)
	if slow != null:
		if parent is Entity:
			if slow.stacks > 0:
				slow.stacks -= 1
				SignalBus.status_refreshed.emit(slow, parent)
				if slow.stacks == 0:
					parent.is_slowed = false
					
func handle_fuse() -> void:
	if !parent is Player:
		return
	var status: Status = get_current_status(Status.Type.FUSE)
	if !status:
		return
	if status.stacks > 0:
		status.stacks -= 1
		SignalBus.status_refreshed.emit(status, PlayerManager.player_node)

func get_current_status(status_type: Status.Type) -> Status:
	for current_status: Status in current_statuses:
		if current_status.effect == status_type:
			return current_status
	return null
	
func remove_current_status(status_type: Status.Type) -> void:
	var status_index: int
	var count: int = 0
	for current_status: Status in current_statuses:
		count += 1
		if current_status.effect == status_type:
			status_index = count
			break
	if status_index != null:
		current_statuses.remove_at(status_index)
	
func handle_thorns(target: Entity, attacker: Entity) -> void:
	var thorns: Status = get_current_status(Status.Type.THORNS)
	if thorns == null:
		return
	if target != parent:
		return
	attacker.take_damage(thorns.stacks)
	
func start_burn() -> void:
	burn_timer.start(BURN_DURATION)
	burn_timer.timeout.connect(_on_burn_timer_timeout)
	
func start_poison() -> void:
	poison_timer.start(POISON_DURATION)
	poison_timer.timeout.connect(_on_poison_timer_timeout)

func start_slow() -> void:
	slow_timer.start(SLOW_DURATION)
	slow_timer.timeout.connect(_on_slow_timer_timeout)
	
func add_status(status: Status) -> void:
	if status.effect == Status.Type.BURN:
		start_burn()

	if status.effect == Status.Type.POISON:
		start_poison()
		
	if status.effect == Status.Type.SLOW:
		start_slow()	
	current_statuses.append(status)
