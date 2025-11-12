extends Node2D

# Shop signals
signal currency_changed
signal pack_opened

# Timer signal
signal game_tick

# Draggable signals
signal card_controller_picked_up(card_controller: CardController)
signal card_controller_hovered(card_controller: CardController)
signal card_controller_released

# Card signals
signal card_discarded(card: Card)
signal card_chosen(card: Card)

# Relic signals
signal relic_added(relic: Relic)
