extends Control

@export var tooltip_scene: PackedScene

@export var display: VBoxContainer
@export var pool: Control

func _ready() -> void:
	SignalBus.card_controller_picked_up.connect(_on_card_controller_picked_up)
	SignalBus.card_controller_released.connect(_on_card_controller_released)
	
func _on_card_controller_picked_up(_card_controller: CardController) -> void:
	hide_tooltip_display()
	
func _on_card_controller_released() -> void:
	show_tooltip_display()

func display_tooltip(text: String) -> TooltipData:
	# VBox container will hold its size even after children are moved out of it
	display.size.y = 0
	if pool.get_child_count() == 0:
		var new_tooltip: TooltipData = tooltip_scene.instantiate()
		new_tooltip.label.text = text
		display.add_child(new_tooltip)
		return new_tooltip
	else:
		var old_tooltip: TooltipData = pool.get_child(0)
		old_tooltip.label.text = text
		old_tooltip.reparent(display)
		return old_tooltip
		
func hide_tooltip(tooltip: TooltipData) -> void:
	tooltip.reparent(pool)
	
func hide_all_tooltips() -> void:
	for tooltip: TooltipData in display.get_children():
		tooltip.reparent(pool)

func hide_tooltip_display() -> void:
	display.visible = false
	
func show_tooltip_display() -> void:
	display.visible = true
