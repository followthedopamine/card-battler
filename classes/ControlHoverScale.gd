class_name ControlHoverScale extends Control

@export var scale_amount: Vector2

@export var node_to_scale: Control
@export var node_to_connect_mouse: Control

@onready var original_position: Vector2 = node_to_scale.position
@onready var original_scale: Vector2 = node_to_scale.scale

func _ready() -> void:
	if node_to_connect_mouse == null:
		node_to_connect_mouse = node_to_scale
		
	node_to_connect_mouse.mouse_entered.connect(_on_mouse_entered)
	node_to_connect_mouse.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	original_position = node_to_scale.position
	var original_rect = node_to_scale.get_rect()

	node_to_scale.scale = scale_amount

	var new_rect = node_to_scale.get_rect()
	var new_position: Vector2 = (original_rect.size - new_rect.size) / Vector2(2, 2)

	node_to_scale.position = new_position
	
func _on_mouse_exited() -> void:
	node_to_scale.scale = original_scale
	node_to_scale.position = original_position
