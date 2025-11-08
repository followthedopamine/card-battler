class_name CardController extends Control

const ROTATION_AMOUNT: float = 1.0
const MAX_ROTATION: float = 50.0


# If we don't hard code this path in we'll have to set it up for every new card
var card_components_scene: PackedScene = preload("res://scenes/card/CardComponents.tscn")
var card_components: CardComponents
var switch_interface: TextureRect
var timer_label: Label
var timer_spinner: Panel
var timer: Timer
var panel: Panel

@onready var hbox: HBoxContainer = get_parent()


var dragging_node : CardController = null
var threshold := 130
var dragging := false


var held_card_controller: CardController
var hovered_card_controller: CardController

var mouse_pos: Vector2
var previous_mouse_pos: Vector2
var smooth_velocity: Vector2

func _ready() -> void:
	SignalBus.card_controller_picked_up.connect(_on_card_controller_picked_up)
	SignalBus.card_controller_hovered.connect(_on_card_controller_hovered)
	mouse_entered.connect(_on_mouse_entered)
	
	card_components = card_components_scene.instantiate()
	add_child(card_components)
	switch_interface = card_components.switch_interface
	timer_label = card_components.timer_label
	timer_spinner = card_components.timer_spinner
	timer = card_components.timer
	panel = card_components.panel
	
	

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
	
	#This sucks but getting the panel after removing the script is really hard.
	var dragging_panel: Panel = dragging_node.get_node("CardComponents/Panel")
	dragging_panel.add_theme_stylebox_override("panel", new_style)

	set_drag_preview(preview_parent)
	set_process_input(true)
	panel.hide()
	dragging = true
	SignalBus.card_controller_picked_up.emit(self)
	
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
					self.reparent(hovered_card_controller.get_parent())
		# if dragging left/right update the position in the parent
		if dragging_node.global_position.x < global_position.x - threshold:
			if self.get_index() > 0:
				# Have to use get_parent() here instead of hbox because the parent
				# of the card can change while dragging.
				get_parent().move_child(self, self.get_index() - 1)
		elif dragging_node.global_position.x > global_position.x + threshold:
			if self.get_index() < get_parent().get_child_count() - 1:
				get_parent().move_child(self, self.get_index() + 1)
				
	
		
func _on_card_controller_picked_up(card_controller: CardController) -> void:
	held_card_controller = card_controller
	
func _on_mouse_entered() -> void:
	SignalBus.card_controller_hovered.emit(self)
	
func _on_card_controller_hovered(card_controller: CardController) -> void:
	if card_controller != held_card_controller:
		hovered_card_controller = card_controller
		
func add_tooltip(tooltip_string: String) -> void:
	Tooltip.new(tooltip_string, self)
		
func end_drag() -> void:
	held_card_controller = null
	dragging = false
	panel.show()
	set_process_input(false)
	update_mouse()
	# Probably want to connect this deferred
	SignalBus.card_controller_released.emit()
	
func update_mouse() -> void:
	# This is the worst shit ever straight up.
	# But it's a workaround for this issue: https://github.com/godotengine/godot/issues/87203
	# Basically the tooltip won't display after ending the drag unless you move the mouse.
	# So we fake moving the mouse.
	warp_mouse(get_local_mouse_position())

func handle_switch_interface() -> void:
	if dragging:
		return
	if self.activated:
		hide_switch_interface()
		return
	
	if !self.get_global_rect().has_point(mouse_pos):
		hide_switch_interface()
		return
		
	if held_card_controller == null:
		return
		
	if held_card_controller.get_parent() is Hand:
		hide_switch_interface()
		return
		
	if !get_parent() is Hand:
		hide_switch_interface()
		return
		
	if held_card_controller.get_parent() != self.get_parent():
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
