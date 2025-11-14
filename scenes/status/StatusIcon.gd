class_name StatusIcon extends TextureRect

@export var label: RichTextLabel

var effect: Status.Type

var stacks: 
	get: return stacks
	set(value):
		stacks = value
		update_label()

func update_label() -> void:
	label.text = str(stacks)
