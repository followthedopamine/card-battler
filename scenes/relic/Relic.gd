class_name Relic extends MarginContainer

@export var relic_sprite: Texture2D
@export var relic_name: String
@export var tooltips: Array[String]

var relic_components: RelicComponents

const RELIC_COMPONENTS_SCENE: PackedScene = preload("res://scenes/relic/relic_components/relic_components.tscn")

func _ready() -> void:
	SignalBus.relic_added.connect(_on_relic_added)
	
	relic_components = RELIC_COMPONENTS_SCENE.instantiate()
	relic_components.label.text = ""
	relic_components.texture_rect.texture = relic_sprite
	size = Vector2(100,100)
	self.add_child(relic_components)
	for tooltip_string: String in tooltips:
		Tooltip.new(tooltip_string, self)
	self.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

func _on_relic_added(relic: Relic) -> void:
	if relic == self:
		SignalBus.wave_end.connect(_on_wave_end)
		SignalBus.card_played.connect(_on_card_played)
		SignalBus.card_chosen.connect(_on_card_chosen)
		SignalBus.wave_start.connect(_on_wave_start)
		SignalBus.wave_setup_phase.connect(_on_wave_setup_phase)
		added_effect()
		
func _on_wave_end(wave: int) -> void:
	wave_end_effect(wave)

func _on_card_played(card: Card) -> void:
	card_played_effect(card)
	
func _on_card_chosen(card: Card) -> void:
	card_chosen_effect(card)
	
func _on_wave_start(wave: int) -> void:
	wave_start_effect(wave)
	
func _on_wave_setup_phase() -> void:
	wave_setup_effect()
	
func added_effect() -> void:
	pass
	
func wave_end_effect(_wave: int) -> void:
	pass
	
func card_played_effect(_card: Card) -> void:
	pass
	
func card_chosen_effect(_card: Card) -> void:
	pass
	
func wave_start_effect(_wave: int) -> void:
	pass
	
func wave_setup_effect() -> void:
	pass
