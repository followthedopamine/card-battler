# Dragging functionality modified from https://www.reddit.com/r/godot/comments/y2cvzu/comment/is58mqe/

class_name Card extends Control

signal completed(card: Card)

@export var switch_interface: TextureRect

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

var held_card: Card
var hovered_card: Card

const DISABLED_COLOUR: Color = Color(0.08, 0.08, 0.08, 1.0)

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

	change_colour(colour)

	timer_label.text = "%.1f" % duration
	
	self.mouse_entered.connect(_on_mouse_entered)
	SignalBus.card_dragged.connect(_on_card_dragged)
	SignalBus.card_hovered.connect(_on_card_hovered)
	

func _process(delta: float) -> void:
	if activated:
		time_remaining -= delta
		timer_label.text = "%.1f" % time_remaining
		timer_spinner.rotation += delta * 10
	
	# This looping on every single card which probably isn't the most
	# efficient way to do things. 
	handle_switch_interface()
		
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if !data.get_parent() is Hand:
		switch_cards(data, self)
	else:
		SignalBus.card_chosen.emit(self)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	# Trying to swap with a half activated card seems like a bad idea
	if !self.get_parent() is Hand:
		return false
	return !activated

func _get_drag_data(at_position: Vector2) -> Variant:
	# Prevent currently activated cards from being dragged
	if activated:
		return null
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
	SignalBus.card_dragged.emit(self)
	
	return self

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if PlayerManager.hand_size != PlayerManager.max_hand_size:
				# This should ideally not reference hovered card parent and instead should be the hand
				if !self.get_parent() is Hand:
					self.reparent(hovered_card.get_parent())
		# if dragging left/right update the position in the parent
		if dragging_node.global_position.x < global_position.x - threshold:
			if self.get_index() > 0:
				# Have to use get_parent() here instead of hbox because the parent
				# of the card can change while dragging.
				get_parent().move_child(self, self.get_index() - 1)
		elif dragging_node.global_position.x > global_position.x + threshold:
			if self.get_index() < get_parent().get_child_count() - 1:
				get_parent().move_child(self, self.get_index() + 1)
				

	# if dragging left/right, give it a lil rotation
	if last_position.x > dragging_node.global_position.x:
		dragging_node.rotation_degrees = 5
	else :
		dragging_node.rotation_degrees = -5
	last_position = dragging_node.global_position
	
	
	if dragging and event.is_action_released("click"):
		held_card = null
		dragging = false
		panel.show()
		set_process_input(false)

func _on_timer_timeout() -> void:
	deactivate()
	
func _on_card_dragged(card: Card) -> void:
	held_card = card
	
func _on_mouse_entered() -> void:
	SignalBus.card_hovered.emit(self)
	
func _on_card_hovered(card: Card) -> void:
	if card != held_card:
		hovered_card = card

func handle_switch_interface() -> void:
	if dragging:
		return
	if activated:
		hide_switch_interface()
		return
	if !get_parent() is Hand:
		hide_switch_interface()
		return
		
	var mousePos = get_viewport().get_mouse_position()
	if !self.get_global_rect().has_point(mousePos):
		hide_switch_interface()
		return
		
	if held_card == null:
		return
		
	if held_card.get_parent() != self.get_parent():
		show_switch_interface()
	else:
		hide_switch_interface()

func switch_cards(new_card: Card, old_card: Card) -> void:
	new_card.reparent(old_card.get_parent())
	old_card.get_parent().move_child(new_card, old_card.get_index())
	SignalBus.card_chosen.emit(new_card)
	old_card.queue_free()
	
func show_switch_interface() -> void:
	switch_interface.visible = true
	
func hide_switch_interface() -> void:
	switch_interface.visible = false

func set_colour(index: int):
	colour = colours[index % colours.size()]
	
func change_colour(new_colour: Color) -> void:
	var new_style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	new_style.bg_color = new_colour
	panel.add_theme_stylebox_override("panel", new_style)

func activate():
	timer.start(duration)

	panel.position.y = -10
	change_colour(DISABLED_COLOUR)
	
	time_remaining = duration

	timer_label.show()
	timer_spinner.show()

	activated = true

func deactivate():
	timer.stop()

	panel.position.y = 0
	change_colour(colour)

	timer_label.hide()
	timer_spinner.hide()
	completed.emit(self)

	activated = false
