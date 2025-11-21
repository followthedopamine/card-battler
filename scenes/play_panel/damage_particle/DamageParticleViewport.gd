extends SubViewport

@onready var label_scene: Label = $Label

func set_label(text: String):
	label_scene.text = text

func set_colour(colour: Color):
	label_scene.add_theme_color_override("font_color", colour)
