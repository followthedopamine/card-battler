class_name Relic extends MarginContainer

@export var relic_sprite: Texture2D
@export var relic_name: String
@export var tooltips: Array[String]

const RELIC_COMPONENTS_SCENE: PackedScene = preload("res://scenes/relic/relic_components/relic_components.tscn")

func _ready() -> void:
	SignalBus.relic_added.connect(_on_relic_added)
	
	var relic_components: RelicComponents = RELIC_COMPONENTS_SCENE.instantiate()
	self.add_child(relic_components)
	for tooltip_string: String in tooltips:
		Tooltip.new(tooltip_string, self)
	self.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _on_relic_added(relic: Relic) -> void:
	if relic == self:
		added_effect()
	
func added_effect() -> void:
	pass
