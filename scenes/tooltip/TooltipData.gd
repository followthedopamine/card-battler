class_name TooltipData extends Control

@export var label: RichTextLabel
@export var container: MarginContainer

var attached_node: Control
var tooltip: Tooltip
#var text_to_display: String

func _process(_delta: float) -> void:
	if is_instance_valid(tooltip.node) and !tooltip.node.is_queued_for_deletion():
		label.text = tooltip.update_tooltip_variables()
