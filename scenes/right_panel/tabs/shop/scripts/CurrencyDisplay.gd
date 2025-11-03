extends RichTextLabel
class_name CurrencyDisplay

func _ready() -> void:
	SignalBus.currency_changed.connect(_on_currency_changed)
	
func _on_currency_changed() -> void:
	update_currency_display()
	
func update_currency_display() -> void:
	self.text = str(PlayerManager.currency)
