extends Node2D

var currency: int:
	get:
		return currency
	set(value):
		currency = value
		SignalBus.currency_changed.emit()
		
var currency_modifier: float
		
var hand_size: int
var max_hand_size: int
var hand_node: Hand

var shop_slots: int

var player_node: Player

var last_card_activated: Card

var enemy_area: EnemyArea

func _init() -> void:
	initialise_vars()
	
func initialise_vars() -> void:
	currency = 20000
	currency_modifier = 1.0
	hand_size = 3
	max_hand_size = 5
	shop_slots = 2
	player_node = null
	last_card_activated = null
	enemy_area = null
	
func reset() -> void:
	print("Resetting PlayerManager")
	initialise_vars()
