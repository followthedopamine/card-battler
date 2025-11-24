class_name CardDisplayCopy extends Control

var card_components_to_copy: CardComponents
var display_card_components: CardComponents

# This is a fake init on purpose since we need to set the script and set_script
# throws an error with a param.
func init(card_to_copy: Card) -> void:
	card_components_to_copy = card_to_copy.card_components
	display_card_components = self.get_child(0)

func _process(_delta: float) -> void:
	display_card_components.timer_spinner.rotation = card_components_to_copy.timer_spinner.rotation
	display_card_components.timer_label.visible = card_components_to_copy.timer_label.visible
	display_card_components.timer_spinner.visible = card_components_to_copy.timer_spinner.visible
	display_card_components.timer_label.text = card_components_to_copy.timer_label.text
	display_card_components.timer_panel.scale = card_components_to_copy.timer_panel.scale
