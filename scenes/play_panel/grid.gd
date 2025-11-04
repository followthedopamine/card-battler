extends Sprite2D

@export var vertical_lines = 15
@export var speed = 24

var horizontal_lines = 6

var elapsed := 0.0

@onready var parent: Control = get_node("..")

func resize():
	if is_instance_valid(parent):
		set_region_rect(Rect2(parent.global_position, parent.size))
		global_position = parent.global_position

func _draw():
	var line_top = region_rect.size.y * 0.5
	var line_bottom = region_rect.size.y
	var width = region_rect.size.x
	var v_centre = region_rect.size.x * .5

	for i in range(vertical_lines + 1):
		var top_x = -fmod(elapsed * speed, (width / vertical_lines)) + (width / vertical_lines) * i + 1
		var bottom_x = top_x + (top_x - v_centre)
		draw_line(Vector2(top_x, line_top), Vector2(bottom_x, line_bottom), Color.CYAN, 0.5, true)

	var horizontal_slice = line_top / horizontal_lines

	var j :float = 0
	for i in range(1, horizontal_lines):
		j += horizontal_lines - i
		var line_height = line_bottom - (horizontal_slice * i) - j
		draw_line(Vector2(0, line_height), Vector2(width, line_height), Color.CYAN, 0.5, true)


func _on_grid_container_resized():
	resize()

func _ready() -> void:
	resize()
	print(self.get_path())


func _process(_delta: float) -> void:
	elapsed += _delta
	queue_redraw()
