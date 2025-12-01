extends Panel

@export var relic_container: MarginContainer
@export var relic_skip_button: Button
@export var relic_name_label: Label

@export var relic: Relic

const REWARD_WAVES: Array[int] = [5,20,50,100,200,300,400]

func _ready() -> void:
	SignalBus.wave_end.connect(_on_wave_end)
	relic_skip_button.pressed.connect(_on_relic_skip_button_pressed)
	relic_container.gui_input.connect(_on_relic_container_gui_input)
	visible = false
	
func _on_wave_end(wave: int) -> void:
	if wave in REWARD_WAVES:
		if GameData.relics.size() == 0:
			return
		offer_relic()
		visible = true

func _on_relic_skip_button_pressed() -> void:
	SignalBus.button_pressed.emit()
	visible = false
	
func _on_relic_container_gui_input(event: InputEvent) -> void:
	if event.is_action_released("click"):
		SignalBus.relic_added.emit(relic)
		visible = false
		
func offer_relic() -> void:
	SignalBus.relic_offered.emit()
	# Don't duplicate since we don't want duplicate relics
	if relic_container.get_child_count() > 0:
		for child: Control in relic_container.get_children():
			child.queue_free()
	var random_relic: Relic = GameData.relics.pop_at(randi_range(0, GameData.relics.size() - 1))
	relic = random_relic
	relic_name_label.text = relic.relic_name
	relic_container.add_child(random_relic)
