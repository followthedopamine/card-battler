extends Node2D

# Shop signals
signal currency_changed
signal pack_opened

# Card signals
signal card_dragged(card: Card)
signal card_hovered(card: Card)
signal card_discarded(card: Card)
signal card_chosen(card: Card)
