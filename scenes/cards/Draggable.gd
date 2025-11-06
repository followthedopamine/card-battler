class_name Draggable extends Control

const ROTATION_AMOUNT: float = 1.0
const MAX_ROTATION: float = 50.0

@export var switch_interface: TextureRect

@onready var panel: Panel = $Panel

var dragging_node : Control = null
var threshold := 130
var dragging := false


var held_draggable: Draggable
var hovered_draggable: Draggable

var mouse_pos: Vector2
var previous_mouse_pos: Vector2
var smooth_velocity: Vector2

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	SignalBus.draggable_picked_up.connect(_on_draggable_picked_up)
	SignalBus.draggable_hovered.connect(_on_draggable_hovered)

func _process(delta) -> void:
	# This looping on every single card which probably isn't the most
	# efficient way to do things.
	previous_mouse_pos = mouse_pos
	mouse_pos = get_viewport().get_mouse_position()
	handle_switch_interface()
	if dragging:
		handle_rotation(delta)
		
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if !data.get_parent() is Hand:
		switch_cards(data, self)
	else:
		# Need this check to prevent pack closing on shuffling hand with pack open
		if !get_parent() is Hand:
			SignalBus.card_chosen.emit(self)

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	if !self.get_parent() is Hand:
		return false
	# Trying to swap with a half activated card seems like a bad idea
	return !self.activated

func _get_drag_data(at_position: Vector2) -> Variant:
	# Prevent currently activated cards from being dragged
	if self.activated:
		return null
	var preview_parent = Control.new()

	dragging_node = self.duplicate()
	dragging_node.set_script(null)
	preview_parent.add_child(dragging_node)
	dragging_node.position = -at_position
	dragging_node.z_index = 100

	# add a little shadow when card is picked up
	var new_style = panel.get_theme_stylebox("panel").duplicate()
	new_style.shadow_color.a = 0.3
	new_style.shadow_size = 8
	new_style.shadow_offset	= Vector2(3, 3)
	var dragging_panel: Panel = dragging_node.get_node("Panel")
	dragging_panel.add_theme_stylebox_override("panel", new_style)

	set_drag_preview(preview_parent)
	set_process_input(true)
	panel.hide()
	dragging = true
	SignalBus.draggable_picked_up.emit(self)
	
	return self
	
func _input(event: InputEvent) -> void:
	# Default Godot dragging behaviour will destroy our preview and crash us
	# on right click if we don't explicity handle it.
	if event.is_action_pressed("right_click"):
		end_drag()
		return
		
	if dragging and event.is_action_released("click"):
		end_drag()
		return
		
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if PlayerManager.hand_size != PlayerManager.max_hand_size:
				# This should ideally not reference hovered card parent and instead should be the hand
				if !self.get_parent() is Hand:
					self.reparent(hovered_draggable.get_parent())
		# if dragging left/right update the position in the parent
		if dragging_node.global_position.x < global_position.x - threshold:
			if self.get_index() > 0:
				# Have to use get_parent() here instead of hbox because the parent
				# of the card can change while dragging.
				get_parent().move_child(self, self.get_index() - 1)
		elif dragging_node.global_position.x > global_position.x + threshold:
			if self.get_index() < get_parent().get_child_count() - 1:
				get_parent().move_child(self, self.get_index() + 1)
				
	
		
func _on_draggable_picked_up(draggable: Draggable) -> void:
	held_draggable = draggable
	
func _on_mouse_entered() -> void:
	SignalBus.draggable_hovered.emit(self)
	
func _on_draggable_hovered(draggable: Draggable) -> void:
	if draggable != held_draggable:
		hovered_draggable = draggable
		
func end_drag() -> void:
	held_draggable = null
	dragging = false
	panel.show()
	set_process_input(false)
	# Probably want to connect this deferred
	SignalBus.draggable_released.emit()

func handle_switch_interface() -> void:
	if dragging:
		return
	if self.activated:
		hide_switch_interface()
		return
	
	if !self.get_global_rect().has_point(mouse_pos):
		hide_switch_interface()
		return
		
	if held_draggable == null:
		return
		
	if held_draggable.get_parent() is Hand:
		hide_switch_interface()
		return
		
	if !get_parent() is Hand:
		hide_switch_interface()
		return
		
	if held_draggable.get_parent() != self.get_parent():
		show_switch_interface()
	else:
		hide_switch_interface()
		
func handle_rotation(delta) -> void:
	# Maybe for added effect in the future we could change the pivot point of 
	# the dragged card - for now though this looks fine I think.
	
	# if dragging left/right, give it a lil rotation (based on mouse velocity)
	# This is almost definitely not the right way to use delta here but it does
	# at least fix rotation going completely crazy on low fps.
	var mouse_vel: Vector2 = (mouse_pos - previous_mouse_pos) / delta * ROTATION_AMOUNT
	# Add delta here because on low fps our card will rotate more so we need it to
	# lerp faster to return to normal rotation at a sensible speed.
	smooth_velocity = smooth_velocity.lerp(mouse_vel, 0.1 + delta)  
		
	var direction: float = -1.0
	if smooth_velocity.x > 0.0:
		direction = 1.0
	
	dragging_node.rotation_degrees = clampf(direction * smooth_velocity.length() * delta, -MAX_ROTATION, MAX_ROTATION)

func switch_cards(new_card: Card, old_card: Card) -> void:
	new_card.reparent(old_card.get_parent())
	old_card.get_parent().move_child(new_card, old_card.get_index())
	SignalBus.card_chosen.emit(new_card)
	old_card.queue_free()
	
func show_switch_interface() -> void:
	switch_interface.visible = true
	
func hide_switch_interface() -> void:
	switch_interface.visible = false
