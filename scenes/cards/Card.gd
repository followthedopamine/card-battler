# Dragging functionality modified from https://www.reddit.com/r/godot/comments/y2cvzu/comment/is58mqe/

class_name Card extends Draggable

signal completed(card: Card)

@export var price: int = 5

@export_range(0.0, 5.0) var duration := 2.0
var time_remaining := duration

@onready var timer_label: Label = $Panel/TimerLabel
@onready var timer_spinner: Panel = $Panel/Spinner

@onready var hbox: HBoxContainer = get_parent()
@onready var timer: Timer = $Timer

# Draggable dependant on this existing
var activated := false

const DISABLED_COLOUR: Color = Color(0.08, 0.08, 0.08, 1.0)

const colours := [
	Color(255, 0, 0),
	Color(0, 255, 0),
	Color(0, 0, 255),
	Color(255, 0, 255),
	Color(255, 255, 0),
	Color(0, 255, 255)
]
var colour: Color;

func _ready() -> void:
	super()
	set_process_input(false)

	change_colour(colour)

	timer_label.text = "%.1f" % duration

func _process(delta: float) -> void:
	super(delta)
	if activated:
		time_remaining -= delta
		timer_label.text = "%.1f" % time_remaining
		timer_spinner.rotation += delta * 10

func _on_timer_timeout() -> void:
	deactivate()

func set_colour(index: int):
	colour = colours[index % colours.size()]
	
func change_colour(new_colour: Color) -> void:
	var new_style: StyleBoxFlat = panel.get_theme_stylebox("panel").duplicate()
	new_style.bg_color = new_colour
	panel.add_theme_stylebox_override("panel", new_style)

func activate():
	timer.start(duration)

	panel.position.y = -10
	change_colour(DISABLED_COLOUR)
	
	time_remaining = duration

	timer_label.show()
	timer_spinner.show()

	activated = true

func deactivate():
	timer.stop()

	panel.position.y = 0
	change_colour(colour)

	timer_label.hide()
	timer_spinner.hide()
	completed.emit(self)

	activated = false
