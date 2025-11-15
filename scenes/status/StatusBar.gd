class_name StatusBar extends HBoxContainer

@export var status_icon_scene: PackedScene

@onready var parent: Control = get_parent()

func _ready() -> void:
	# Possibly want to initialise a copy of all status effects so that we aren't
	# freeing them and instantiating them over and over
	SignalBus.status_updated.connect(_on_status_updated)
	SignalBus.block_updated.connect(_on_block_updated)

func _on_status_updated(status: Status, node: Node) -> void:
	if node == parent:
		update_status_bar(status)

func _on_block_updated(node: Node) -> void:
	if node == parent:
		var status: Status = Status.new()
		status.effect = Status.Type.BLOCK
		status.stacks = node.block
		update_status_bar(status, true)

func update_status_bar(status: Status, should_equal_stacks: bool = false):
	if get_child_count() == 0:
		add_status_icon(status)
		return
	for child: StatusIcon in get_children():
		if child.effect == status.effect:
			if should_equal_stacks:
				child.stacks = status.stacks
			else:
				child.stacks += status.stacks
			return
	add_status_icon(status)

func add_status_icon(status: Status):
	var icon: StatusIcon = status_icon_scene.instantiate()
	icon.stacks = status.stacks
	icon.effect = status.effect
	self.add_child(icon)
	
