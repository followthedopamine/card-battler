extends Node2D

var currency: int = 100 :
	get:
		return currency
	set(value):
		currency = value
		SignalBus.currency_changed.emit()

var shop_slots: int = 2
