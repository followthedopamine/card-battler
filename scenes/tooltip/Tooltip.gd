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
	var updated_text = update_tooltip_variables(text)
	tooltip = TooltipCanvas.display_tooltip(updated_text)
	position_tooltip()
	
func _on_mouse_exited() -> void:
	TooltipCanvas.hide_tooltip(tooltip)
	
func update_tooltip_variables(text_with_variables: String) -> String:
	var re = RegEx.new()
	re.compile("%([^%]+)%")
	var matches = re.search_all(text_with_variables)
	if matches.size() == 0:
		return text
	var last_index = 0
	var replaced_text: String = ""
	for variable in matches:
		var start := variable.get_start()
		var end := variable.get_end()
		var variable_string = variable.get_string()
		variable_string = variable_string.lstrip('%')
		variable_string = variable_string.rstrip('%')
		replaced_text += text_with_variables.substr(last_index, start - last_index)
		if variable_string in node:
			replaced_text += str(node.get(variable_string))
		else:
			print("Tried to include a variable in tooltip that doesn't exist on node %s" % node)
		last_index = end
	replaced_text += text_with_variables.substr(last_index, text_with_variables.length() - last_index)
	return replaced_text
	
func position_tooltip() -> void:
	var x = node.get_rect().size.x + node.global_position.x
	var y = node.global_position.y

	var viewport_rect: Rect2 = node.get_viewport().get_visible_rect()

	TooltipCanvas.display.global_position = Vector2(x, y)
	# TODO: Handle tooltip going over edge of screen on the right side (no way to test currently)
	if TooltipCanvas.display.global_position.y + TooltipCanvas.display.size.y > viewport_rect.position.y + viewport_rect.size.y:
		var difference: float = (TooltipCanvas.display.global_position.y + TooltipCanvas.display.size.y) - (viewport_rect.position.y + viewport_rect.size.y)
		TooltipCanvas.display.global_position -= Vector2(0, difference + BOTTOM_PADDING)
	
