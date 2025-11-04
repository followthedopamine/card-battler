extends Node2D

var currency: int = 100 :
	get:
		return currency
	set(value):
		currency = value
		SignalBus.currency_changed.emit()
		
var hand_size := 3
var max_hand_size := 5

var shop_slots: int = 2
