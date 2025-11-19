extends Node2D

# Shop signals
signal currency_changed
signal pack_opened
signal pack_closed

# Draggable signals
signal card_controller_picked_up(card_controller: CardController)
signal card_controller_hovered(card_controller: CardController)
signal card_controller_released

# Card signals
signal card_discarded(card: Card)
signal card_chosen(card: Card)
signal card_played

# Status signals
signal status_updated(status: Status, attached_node: Node)
signal status_refreshed(status: Status, attached_node: Node)
signal block_updated(blocking_entity: Node)
signal strength_updated(strength_entity: Entity)

# Relic signals
signal relic_added(relic: Relic)

# Entity signals
signal damage_taken(target: Entity, attacker: Entity)

# PlayPanel signals
signal enemy_area_setup()

signal enemies_cleared()
signal wave_start(wave: int)
signal wave_end(wave: int)

## t = timer
signal animation_wave_t(eased_t: float)
signal animation_grid_offset(offset: int)
signal animation_end()

signal enemy_attack(damage: float, enemy: Enemy)
signal enemy_dead(payout: int)

signal player_max_health(new_value: int)
signal player_health_change(new_value: int)

signal card_played_target_enemy(card: Card)
signal card_played_target_player(card_effect: Dictionary)
signal card_played_target_shop(card_effect: Dictionary)
