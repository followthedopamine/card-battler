class_name CardEffect
extends ActionEffect

## ECONOMY 
## Coins given or taken on playing the card
@export var currency: int

func modify_currency(coin_amount: int):
	var modified_currency = floori(coin_amount * PlayerManager.currency_modifier)
	PlayerManager.currency += modified_currency

func run_effects():
	match target:
		Target.ENEMY:
			SignalBus.card_played_target_enemy.emit(self)
			SignalBus.player_dealt_damage.emit()
		Target.PLAYER:
			SignalBus.card_played_target_player.emit(self, null)
			if on_play_all_enemy_callables.size():
				SignalBus.card_played_target_enemy.emit(self)
		Target.SHOP:
			SignalBus.card_played_target_shop.emit(self)
	
	if (currency): 
		modify_currency(currency)

	if (on_play_callables.size()): 
		run_on_play_callables()
