extends ProgressBar

func set_max_health(health: int, refill_health = true):
	max_value = health

	if refill_health:
		set_health(health)
	
func set_health(health: int):
	value = health

func reduce_health(health: int):
	value -= health
