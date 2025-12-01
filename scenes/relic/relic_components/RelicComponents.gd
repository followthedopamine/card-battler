class_name RelicComponents extends Control

@export var texture_rect: TextureRect
@export var label: RichTextLabel

@onready var control_hover_scale = $ControlHoverScale

func set_hover_scale(scale_amount: float):
	if is_instance_valid(control_hover_scale):
		control_hover_scale.scale_amount = Vector2(scale_amount, scale_amount)
