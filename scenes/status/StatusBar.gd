class_name StatusBar extends HBoxContainer

@export var status_icon_scene: PackedScene

@onready var parent: Control = get_parent()

func _ready() -> void:
	# Possibly want to initialise a copy of all status effects so that we aren't
	# freeing them and instantiating them over and over
	SignalBus.status_updated.connect(_on_status_updated)

func _on_status_updated(status: Status, node: Node) -> void:
	if node == parent:
		update_status_bar(status)

func update_status_bar(status: Status):
	if get_child_count() == 0:
		add_status_icon(status)
		return
	for child: StatusIcon in get_children():
		if child.effect == status.effect:
			child.stacks += status.stacks
			return
	add_status_icon(status)

func add_status_icon(status: Status):
	var icon: StatusIcon = status_icon_scene.instantiate()
	icon.stacks = status.stacks
	self.add_child(icon)
	
