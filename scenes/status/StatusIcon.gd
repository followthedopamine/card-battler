class_name StatusIcon extends TextureRect

@export var label: RichTextLabel

@export var slow_texture: Texture
@export var block_texture: Texture
@export var thorns_texture: Texture
@export var strength_texture: Texture


var effect: Status.Type

var stacks: 
	get: return stacks
	set(value):
		stacks = value
		update_label()
		
func _ready() -> void:
	update_texture()

func update_label() -> void:
	label.text = str(stacks)

func update_texture() -> void:
	match effect:
		Status.Type.SLOW:
			self.texture = slow_texture
		Status.Type.BLOCK:
			self.texture = block_texture
		Status.Type.THORNS:
			self.texture = thorns_texture
		Status.Type.STRENGTH:
			self.texture = strength_texture
