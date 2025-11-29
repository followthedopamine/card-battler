extends AnimatedSprite2D

@export var shop_reroll_button: Button

var parent_size = Vector2.ZERO

var blink_timer: Timer = Timer.new()

@onready var parent: MarginContainer = get_parent()

func resize():
	if is_instance_valid(parent):
		var texture_size := sprite_frames.get_frame_texture(animation, 0).get_size()
		var scale_value = parent.size.y / texture_size.y
		scale = Vector2(scale_value, scale_value)

		global_position = parent.global_position + (parent.size / 2)

func blink():
	animation = "blink"
	play()

func pack_eject():
	# don't interrupt this animation with a blink
	blink_timer.paused = true
	animation = "pack_eject"
	play()

func _on_animation_finish():
	if animation == "pack_eject":
		blink_timer.paused = false

	if animation != "default":
		animation = "default"
		pause()

func _on_blink_timer_timeout():
	blink()
	var blink_time = randf_range(8, 20)
	blink_timer.wait_time = blink_time
	blink_timer.start()

func _ready() -> void:
	call_deferred("resize")
	animation_finished.connect(_on_animation_finish)

	var blink_time = randf_range(8, 20)
	blink_timer.wait_time = blink_time
	blink_timer.one_shot = true
	blink_timer.timeout.connect(_on_blink_timer_timeout)

	add_child(blink_timer)
	blink_timer.start()

	shop_reroll_button.pressed.connect(_on_shop_reroll_button_pressed)

func _on_shop_reroll_button_pressed() -> void:
	pack_eject()

func _process(_delta: float) -> void:
	# Resize is handled here instead of with the signal as the signal seems
	# to miss some forms of resizing (eg. toggling full screen)
	if parent.size != parent_size:
		parent_size = parent.size
		resize()
