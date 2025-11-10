extends MarginContainer
class_name RightPanelTabs

@export var shop_button: Button
@export var stats_button: Button
@export var settings_button: Button

@export var shop_tab: Control
@export var stats_tab: VBoxContainer
@export var settings_tab: VBoxContainer

func _ready() -> void:
	shop_button.pressed.connect(_on_shop_button_pressed)
	stats_button.pressed.connect(_on_stats_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)
	
func _on_shop_button_pressed() -> void:
	hide_all_tabs()
	shop_tab.visible = true
	
func _on_stats_button_pressed() -> void:
	hide_all_tabs()
	stats_tab.visible = true
	
func _on_settings_button_pressed() -> void:
	hide_all_tabs()
	settings_tab.visible = true
	
func hide_all_tabs() -> void:
	shop_tab.visible = false
	stats_tab.visible = false
	settings_tab.visible = false
