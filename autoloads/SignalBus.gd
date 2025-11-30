extends Node2D

# Shop signals
signal currency_changed
signal pack_opened(rarity: PackOpening.Rarity)
signal pack_closed
signal shop_rerolled

# Draggable signals
signal card_controller_picked_up(card_controller: CardController)
signal card_controller_hovered(card_controller: CardController)
signal card_controller_released
signal card_controller_position_changed

# Card signals
signal card_discarded(card: Card)
signal card_chosen(card: Card)
signal card_played(card: Card)
signal card_enabled
signal card_duration_changed(card: Card)

# Status signals
signal status_updated(status: Status, attached_node: Node)
signal status_refreshed(status: Status, attached_node: Node)
signal block_updated(blocking_entity: Node)
signal strength_updated(strength_entity: Entity)

# Relic signals
signal relic_added(relic: Relic)

# Entity signals
signal player_died
signal damage_taken(target: Entity, attacker: Entity, damage: float)
signal buffed(target: Entity)

# PlayPanel signals

signal enemies_cleared()
signal wave_start(wave: int)
signal wave_end(wave: int)
signal wave_setup_phase

## t = timer
signal animation_wave_t(eased_t: float)
signal animation_end()

signal enemy_attack(damage: float, enemy: Enemy)
signal enemy_dead(payout: int)

signal player_max_health(new_value: int)
signal player_health_change(new_value: int)

signal card_played_target_enemy(card_effect: CardEffect)
signal card_played_target_player(card_effect: CardEffect)
signal card_played_target_shop(card_effect: CardEffect)

## equivalent of card_played_target_enemy without trigger `card_played` effects
signal enemy_targeted(effect: ActionEffect)
signal player_targeted(effect: ActionEffect, source: Enemy)

# wave controller signals
signal wave_controller_enemy_area_loaded(area: EnemyArea)
signal wave_controller_grid_loaded(grid: Sprite2D)

# Audio signals
signal sfx_volume_changed(value: float)
signal music_volume_changed(value: float)
signal button_pressed
signal player_dealt_damage
signal player_healed
signal player_added_block
signal relic_offered
signal lose
signal card_sold

func reset() -> void:
	print("Resetting")
	
