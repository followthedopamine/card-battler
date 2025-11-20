class_name Hand extends HBoxContainer

var cards: Array[Card]

func _ready() -> void:
	SignalBus.wave_end.connect(_on_wave_end)
	SignalBus.card_enabled.connect(_on_card_enabled)
	SignalBus.card_chosen.connect(_on_card_chosen)
	
	var starter_card: Card = GameData.cards_common[0].duplicate()
	draw(starter_card)
	start_round()
	PlayerManager.hand_node = self
	
func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return !PlayerManager.hand_size == PlayerManager.max_hand_size
	
# Hand needs drop data as well as Card since you want to be able to drop 
# cards into an empty hand.
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.reparent(self)
	SignalBus.card_chosen.emit(data)

func _on_wave_end(_wave: int) -> void:
	# This is for resetting stacking card effects on next wave
	# Also has a bonus of starting the hand over from the leftmost card
	for card: Card in cards:
		if card.original_card_effect != null:
			card.card_effect = card.original_card_effect.duplicate_deep(Resource.DeepDuplicateMode.DEEP_DUPLICATE_ALL)
		card.deactivate()
	start_round()

func _on_card_enabled() -> void:
	if get_active_card() == null:
		start_round()
		
func _on_card_chosen(_card: Card) -> void:
	if get_active_card() == null:
		start_round()
	
func get_active_card() -> Card:
	refresh_card_array()
	for card: Card in cards:
		if card.activated:
			return card
	return null
	
func refresh_card_array() -> void:
	cards = []
	for child: Node in self.get_children():
		if !is_instance_valid(child) or child.is_queued_for_deletion():
			continue
		if child is Card:
			if !child.completed.is_connected(on_card_completed):
				child.connect("completed", on_card_completed)
			cards.append(child)
	
	PlayerManager.hand_size = cards.size()

func start_round():
	print("Starting round")

	refresh_card_array()
	if cards.size():
		if !cards[0].is_disabled:
			cards[0].activate()
		else:
			activate_next_card(cards[0])
#
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
	activate_next_card(card)
	
func get_next_card(current_card: Card) -> Card:
	if cards.size() <= 1:
		return current_card
	var current_card_index = cards.find(current_card)
	if current_card_index == cards.size() - 1:
		current_card_index = -1
	return cards[current_card_index + 1]
	
func get_next_playable_card(current_card: Card) -> Card:
	var current_card_index = cards.find(current_card)
	for i: int in range(1, cards.size() + 1):
		var next_card_index = (i + current_card_index) % cards.size()
		if cards[next_card_index].is_disabled:
			continue
		return cards[next_card_index]
	return null

func get_all_playable_cards(extra_cards: Array[Card] = []) -> Array[Card]:
	var playable_cards: Array[Card] = []
	for card: Card in cards:
		if card in extra_cards:
			playable_cards.append(card)
			continue
		if card.is_disabled:
			continue
		playable_cards.append(card)
	return playable_cards
	
func activate_next_card(current_card: Card) -> void:
	refresh_card_array()
	var next_playable_card: Card = get_next_playable_card(current_card)
	if next_playable_card != null:
		next_playable_card.activate()
	
