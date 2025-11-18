class_name Status extends Node

enum Type {
	BURN,
	SLOW,
	BLOCK,
	THORNS,
	STRENGTH,
	EXTRA_ATTACK
}

var effect: Type = Type.BURN

var stacks: int = 3

func _init(status_effect: Type, status_stacks: int, entity: Entity, should_emit: bool = true) -> void:
	effect = status_effect
	stacks = status_stacks
	if should_emit:
		SignalBus.status_updated.emit(self, entity)

static func get_status(entity: Entity, status_type: Status.Type) -> Status:
	for child in entity.get_children():
		if child is StatusHandler:
			var status: Status = child.get_current_status(status_type)
			if status != null:
				return status
	return null
	
