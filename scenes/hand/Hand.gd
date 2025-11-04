class_name Hand extends HBoxContainer


@export var card_scene : PackedScene

var cards: Array[Card]

func _ready() -> void:
	#SignalBus.card_discarded.connect(_on_card_discarded)
	
	for i in range(PlayerManager.hand_size):
		var new_card = card_scene.instantiate()
		new_card.set_colour(i)

		if not draw(new_card):
			new_card.queue_free()

	start_round()
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return !PlayerManager.hand_size == PlayerManager.max_hand_size
	
# Hand needs drop data as well as Card since you want to be able to drop 
# cards into an empty hand.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.reparent(self)
	SignalBus.card_chosen.emit(data)
	
	
func refresh_card_array() -> void:
	cards = []
	for child: Node in self.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Card:
			if !child.completed.is_connected(on_card_completed):
				child.connect("completed", on_card_completed)
			cards.append(child)
	
	PlayerManager.hand_size = cards.size()

func start_round():
	print("Starting round")

	cards = []
	for child in get_children():
		if child is Card:
			cards.append(child)

	cards[0].activate()

func draw_random() -> void:
	var new_card = card_scene.instantiate()
	new_card.set_colour(randi())

	if not draw(new_card):
		new_card.queue_free()

func draw(card: Card) -> bool:
	if cards.size() >= PlayerManager.max_hand_size:
		return false

	card.connect("completed", on_card_completed)
	cards.append(card)
	add_child(card)
	return true


func on_card_completed(card: Card):
	# Calling refresh card array here means we don't have to signal when
	# we get a new card, and also fixes a bug where cards would sometimes
	# activate out of order.
	refresh_card_array()
	var i = cards.find(card)

	if i < cards.size() - 1:
		cards[i + 1].activate()
	else:
		start_round()
