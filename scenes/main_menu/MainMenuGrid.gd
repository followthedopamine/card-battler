extends Sprite2D

@export var vertical_lines = 17
@export var horizontal_lines = 50
@export var horizontal_spacing := 0.2

@export var area_parent: Control

## Used for the main menu and testing
@export var speed := 0
var time_elapsed := 0.0


var parent_size = Vector2.ZERO

var draw_offset := 0.0
@onready var parent: Control = get_parent()

func resize():
	if is_instance_valid(parent):
		set_region_rect(Rect2(parent.global_position, parent.size))
		global_position = parent.global_position

func get_lines():
	return Vector2(vertical_lines, horizontal_lines)

func _on_animation_wave_t(eased_t: float):
	var vertical_slice = (region_rect.size.x / vertical_lines)
	
	draw_offset = lerp(Vector2.ZERO, Vector2(vertical_slice, 0), eased_t).x
	queue_redraw()

func _draw():
	var line_top = region_rect.size.y - area_parent.size.y
	var line_bottom = region_rect.size.y
	var width = region_rect.size.x
	var h_centre = width * .5

	var vertical_slice = width / vertical_lines

	for i in range(vertical_lines + 1):
		var top_x = -fmod(draw_offset + time_elapsed * speed, vertical_slice) + vertical_slice * i + 1
		# pushes the bottom of the line away from the horizontal center of the grid
		# the further it starts from the center the further it is pushed
		var bottom_x = top_x + (top_x - h_centre)
		draw_line(Vector2(top_x, line_top), Vector2(bottom_x, line_bottom), Color.CYAN, 0.5, true)

	var area_height = line_bottom - line_top

	var top_offset = (area_height / (horizontal_lines * horizontal_spacing))
	for i in range(1, horizontal_lines):
		var line_height = line_top + (area_height / (i * horizontal_spacing)) - top_offset 
		draw_line(Vector2(0, line_height), Vector2(width, line_height), Color.CYAN, 0.5, true)

func _ready() -> void:
	resize()

func _process(delta: float) -> void:
	if speed:
		time_elapsed += delta
		queue_redraw()

	# Resize is handled here instead of with the signal as the signal seems 
	# to miss some forms of resizing (eg. toggling full screen)
	if parent.size != parent_size:
		parent_size = parent.size
		resize()
		queue_redraw()
