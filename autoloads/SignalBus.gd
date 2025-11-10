extends Node2D

# Shop signals
signal currency_changed
signal pack_opened

# Timer signal
signal game_tick

# Draggable signals
signal draggable_picked_up(draggable: Draggable)
signal draggable_hovered(draggable: Draggable)

# Card signals
signal card_discarded(card: Card)
signal card_chosen(card: Card)
