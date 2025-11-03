# Dragging functionality modified from https://www.reddit.com/r/godot/comments/y2cvzu/comment/is58mqe/

class_name Card extends Control

signal completed(card: Card)

@export_range(0.0, 5.0) var duration := 2.0
var time_remaining := duration

@onready var panel: Panel = $Panel
@onready var timer_label: Label = $Panel/TimerLabel
@onready var timer_spinner: Panel = $Panel/Spinner

@onready var hbox: HBoxContainer = get_parent()
@onready var timer: Timer = $Timer

var dragging_node : Control = null
var threshold := 130
var last_position: Vector2
var dragging := false
var activated := false

const colours := [
	Color(255, 0, 0),
	Color(0, 255, 0),
	Color(0, 0, 255),
	Color(255, 0, 255),
	Color(255, 255, 0),
	Color(0, 255, 255)
]
var colour: Color;

func _ready() -> void:
	set_process_input(false)

	var new_style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	new_style.bg_color = colour
	panel.add_theme_stylebox_override("panel", new_style)

	timer_label.text = "%.1f" % duration

func _process(delta: float) -> void:
	if activated:
		time_remaining -= delta
		timer_label.text = "%.1f" % time_remaining
		timer_spinner.rotation += delta * 10

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview_parent = Control.new()

	dragging_node = self.duplicate()
	dragging_node.set_script(null)
	preview_parent.add_child(dragging_node)
	dragging_node.position = -at_position

	# add a little shadow when card is picked up
	var new_style = panel.get_theme_stylebox("panel").duplicate()
	new_style.shadow_color.a = 0.3
	new_style.shadow_size = 8
	new_style.shadow_offset  = Vector2(3, 3)
	var dragging_panel: Panel = dragging_node.get_node("Panel")
	dragging_panel.add_theme_stylebox_override("panel", new_style)

	set_drag_preview(preview_parent)
	set_process_input(true)
	panel.hide()
	dragging = true

	return self

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		# if dragging left/right update the position in the hbox (hand)
		if dragging_node.global_position.x < global_position.x - threshold:
			if self.get_index() > 0:
				hbox.move_child(self, self.get_index() - 1)
		elif dragging_node.global_position.x > global_position.x + threshold:
			if self.get_index() < hbox.get_child_count() - 2:
				hbox.move_child(self, self.get_index() + 1)

	# if dragging left/right, give it a lil rotation
	if last_position.x > dragging_node.global_position.x:
		dragging_node.rotation_degrees = 5
	else :
		dragging_node.rotation_degrees = -5
	last_position = dragging_node.global_position

	if dragging and event.is_action_released("click"):
		dragging = false
		panel.show()
		set_process_input(false)

func _on_timer_timeout() -> void:
	deactivate()

func set_colour(index: int):
	colour = colours[index % colours.size()]

func activate():
	timer.start(duration)

	panel.position.y = -10
	time_remaining = duration

	timer_label.show()
	timer_spinner.show()

	activated = true

func deactivate():
	timer.stop()

	panel.position.y = 0

	timer_label.hide()
	timer_spinner.hide()
	completed.emit(self)

	activated = false
