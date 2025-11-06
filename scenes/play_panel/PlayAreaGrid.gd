extends Sprite2D

@export var vertical_lines = 17
@export var speed = 0

var horizontal_lines = 6
var time_elapsed := 0.0

var parent_size = Vector2.ZERO

@onready var parent: Control = get_node("..")

func resize():
	if is_instance_valid(parent):
		set_region_rect(Rect2(parent.global_position, parent.size))
		global_position = parent.global_position

func get_lines():
	return Vector2(vertical_lines, horizontal_lines)

func _draw():
	var line_top = region_rect.size.y * 0.5
	var line_bottom = region_rect.size.y
	var width = region_rect.size.x
	var v_centre = region_rect.size.x * .5

	var vertical_slice = width / vertical_lines

	for i in range(vertical_lines + 1):
		var top_x = -fmod(time_elapsed * speed, vertical_slice) + vertical_slice * i + 1

		# pushes the bottom of the line away from the horizontal center of the grid
		# the further it starts from the center the further it is pushed
		var bottom_x = top_x + (top_x - v_centre)
		draw_line(Vector2(top_x, line_top), Vector2(bottom_x, line_bottom), Color.CYAN, 0.5, true)


	# spacing the horizontal lines for this correctly is surprisingly complicated
	# line_spacing_offset is my 'good enough' workaround
	var line_spacing_offset :float = 0
	var horizontal_slice = line_top / horizontal_lines

	for i in range(1, horizontal_lines):
		line_spacing_offset += horizontal_lines - i
		var line_height = line_bottom - (horizontal_slice * i) - line_spacing_offset
		draw_line(Vector2(0, line_height), Vector2(width, line_height), Color.CYAN, 0.5, true)

func _ready() -> void:
	resize()

func _process(_delta: float) -> void:
	time_elapsed += _delta

	# Resize is handled here instead of with the signal as the signal seems 
	# to miss some forms of resizing (eg. toggling full screen)
	if parent.size != parent_size:
		parent_size = parent.size
		resize()
		queue_redraw()
	elif (speed):
		queue_redraw()
