# Dragging functionality modified from https://www.reddit.com/r/godot/comments/y2cvzu/comment/is58mqe/

class_name Card extends CardController

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
}

enum CardTag {
	MELEE,
	BLOCK,
	BURN,
	SLOW,
	RANDOM,
	THORNS,
	STRENGTH,
	POISON,
	AOE,
	RANGED,
	ALL,
}

const INSTANT_SPEED: float = 0.1

var card_tag_tooltips: Dictionary[CardTag, String] = {
	CardTag.MELEE: "Melee: Can only hit enemies in the closest row",
	CardTag.BLOCK: "Block: Prevents damage",
	CardTag.BURN: "Burn: Deals damage equal to number of burn stacks every %s second" % StatusHandler.BURN_DURATION,
	CardTag.SLOW: "Slow: Reduces the enemy attack speed by %s seconds" % StatusHandler.SLOW_ADDITION,
	CardTag.RANDOM: "Random: Can hit any enemy",
	CardTag.THORNS: "Thorns: Reflects some damage back at the enemy",
	CardTag.STRENGTH: "Strength: Adds damage to your attacks",
	CardTag.POISON: "Poison: Deals damage equal to number of burn every %s second" % StatusHandler.POISON_DURATION,
	CardTag.AOE: "AOE: Hits the target enemy and adjacent enemies",
	CardTag.RANGED: "Ranged: Hits the enemies in the back row first",
	CardTag.ALL: "All: This card targets every enemy at once",
}

signal completed(card: Card)

const MINIMUM_SIZE: Vector2 = Vector2(142.0, 225.0)
const PIVOT_POINT: Vector2 = Vector2(73.0, 22.0)

@export var card_name: String
@export var sprite_texture: Texture2D
@export var tooltips: Array[String] = []
@export var tags: Array[CardTag] = []

@export var price: int = 5
@export var card_effect: CardEffect
@export var rarity: Rarity = Rarity.COMMON

@export_range(0.0, 5.0) var duration := 2.0
var time_remaining := duration

# Draggable dependant on this existing
var activated := false

const DISABLED_COLOUR: Color = Color(0.176, 0.176, 0.176, 1.0)

var is_disabled: bool = false
var disabled_timer: Timer = Timer.new()

const colours := [
	Color(255, 0, 0),
	Color(0, 255, 0),
	Color(0, 0, 255),
	Color(255, 0, 255),
	Color(255, 255, 0),
	Color(0, 255, 255)
]
var colour: Color

var original_card_effect: CardEffect

func _ready() -> void:
	super()
	self.add_child(disabled_timer)
	disabled_timer.timeout.connect(disabled_timeout)
	disabled_timer.one_shot = true
	
	timer.timeout.connect(_on_timer_timeout)
	set_process_input(false)

	#change_colour(colour)

	timer_label.text = "%.1f" % duration
	card_components.sprite.texture = sprite_texture
	card_components.name_label.text = card_name
	
	custom_minimum_size = MINIMUM_SIZE
	pivot_offset = PIVOT_POINT
	
	for tooltip_string: String in tooltips:
		Tooltip.new(tooltip_string, self)
		
	for tag: CardTag in tags:
		if card_tag_tooltips.has(tag):
			Tooltip.new(card_tag_tooltips[tag], self)
	
	if card_effect != null:
		# If we don't do a super thorough duplicate then the resource will never be
		# unique
		original_card_effect = card_effect.duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL)

func _process(delta: float) -> void:
	super(delta)
	if activated:
		time_remaining -= delta
		timer_label.text = "%.1f" % time_remaining
		timer_spinner.rotation += delta * 10

func _on_timer_timeout() -> void:
	activate_card_effect()
	SignalBus.card_played.emit()
	PlayerManager.last_card_activated = self
	deactivate()
	
func activate_card_effect() -> void:
	if is_instance_valid(card_effect):
		card_effect.run_effects()
	else:
		push_error("ERROR: This should not be reachable. In card_name:", card_name, " | ", name)

func start_card_effect() -> void:
	pass
	
func disabled_timeout() -> void:
	# Remember to check if we need to restart playing cards
	is_disabled = false
	card_components.modulate = Color(1.0, 1.0, 1.0, 1.0)
	SignalBus.card_enabled.emit()
	
func disable_card(disabled_duration: float) -> void:
	is_disabled = true
	card_components.modulate = DISABLED_COLOUR
	disabled_timer.start(disabled_duration)

func activate():
	start_card_effect()
	timer.start(duration)

	card_components.position.y = -10
	#change_colour(DISABLED_COLOUR)
	
	time_remaining = duration

	timer_label.show()
	timer_spinner.show()

	

	activated = true

func deactivate(should_emit_completed: bool = true):
	timer.stop()

	card_components.position.y = 0
	#change_colour(colour)
	

	timer_label.hide()
	timer_spinner.hide()
	# Card needs to be deactivated before the signal emits or when there is one
	# card in hand it will lose the signal race to reactivate itself and mess
	# with the visuals.
	activated = false
	completed.emit(self)

## An exposed version of the equivalent function from the attached card effect
## So we can access this directly on individual cards more easily
func add_on_play_callable(callable: Callable):
	card_effect.add_on_play_callable(callable)
