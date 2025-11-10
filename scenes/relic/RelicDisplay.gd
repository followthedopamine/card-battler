class_name RelicDisplay extends HBoxContainer

func _ready() -> void:
	SignalBus.relic_added.connect(_on_relic_added)
	
func _on_relic_added(relic: Relic) -> void:
	# Relic is destroyed even after being reparented because of the way 
	# restocking items works so just create a copy. This isn't the most 
	# efficient way to handle this but it's simple and works and won't have
	# a measurable impact on performance.
	#var relic_copy: Relic = relic.duplicate()
	relic.reparent(self)
	# This seems like a weird place to call this but otherwise we run into the 
	# duplication messing with the signal race.
	#relic.added_effect()
