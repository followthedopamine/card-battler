class_name Hand extends HBoxContainer

@export var hand_size := 5
@export var max_hand_size := 8
@export var card_scene : PackedScene

var cards: Array[Card]

func _ready() -> void:
	SignalBus.card_discarded.connect(_on_card_discarded)
	SignalBus.card_chosen.connect(_on_card_chosen)
	
	for i in range(hand_size):
		var new_card = card_scene.instantiate()
		new_card.set_colour(i)

		if not draw(new_card):
			new_card.queue_free()

	start_round()
	
func _on_card_discarded(card: Card) -> void:
	print(cards)
	cards.erase(card)
	print(cards)
	card.queue_free()

func _on_card_chosen(card: Card) -> void:
	# Refresh the cards array when we get a new card. (Simpler than passing
	# the old card's index).
	cards = []
	for child: Node in self.get_children():
		if child.is_queued_for_deletion():
			continue
		if child is Card:
			cards.append(child)
			
	card.connect("completed", on_card_completed)
	print("After card chosen")
	print(cards)

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
	if cards.size() >= max_hand_size:
		return false

	card.connect("completed", on_card_completed)
	cards.append(card)
	add_child(card)
	return true


func on_card_completed(card: Card):
	var i = cards.find(card)

	if i < cards.size() - 1:
		print("Card completed")
		print(cards)
		cards[i + 1].activate()
	else:
		start_round()
