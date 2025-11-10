extends Node2D

# Shop signals
signal currency_changed
signal pack_opened

# Card signals
signal card_dragged(card: Card)
signal card_hovered(card: Card)
signal card_discarded(card: Card)
signal card_chosen(card: Card)

signal card_played_target_enemy(card_effect: Dictionary)
signal card_played_target_player(card_effect: Dictionary)
signal card_played_target_shop(card_effect: Dictionary)

# PlayPanel signals
signal wave_start(wave: int)
signal enemy_attack(damage: float)
signal enemy_dead(payout: int)
signal player_max_health(new_value: int)
signal player_health_change(new_value: int)

