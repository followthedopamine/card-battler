class_name Tooltip extends Node

const LEFT_PADDING: float = 18.0
const BOTTOM_PADDING: float = 10.0

const TOOLTIP_SCENE: PackedScene = preload("res://scenes/tooltip/Tooltip.tscn")

var text: String
var node: Node
var tooltip: TooltipData

func _init(tooltip_text: String, attached_node: Control) -> void:
	text = tooltip_text
	node = attached_node
	node.mouse_entered.connect(_on_mouse_enter)
	node.mouse_exited.connect(_on_mouse_exited)
	
func _on_mouse_enter() -> void:
	tooltip = TooltipCanvas.display_tooltip(text)
	position_tooltip()
	
func _on_mouse_exited() -> void:
	TooltipCanvas.hide_tooltip(tooltip)
	
func position_tooltip() -> void:
	var x = node.get_rect().size.x + node.global_position.x
	var y = node.global_position.y

	var viewport_rect: Rect2 = node.get_viewport().get_visible_rect()

	TooltipCanvas.display.global_position = Vector2(x, y)
	# TODO: Handle tooltip going over edge of screen on the right side (no way to test currently)
	if TooltipCanvas.display.global_position.y + TooltipCanvas.display.size.y > viewport_rect.position.y + viewport_rect.size.y:
		var difference: float = (TooltipCanvas.display.global_position.y + TooltipCanvas.display.size.y) - (viewport_rect.position.y + viewport_rect.size.y)
		TooltipCanvas.display.global_position -= Vector2(0, difference + BOTTOM_PADDING)
	
