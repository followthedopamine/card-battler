class_name LightFuse extends Card

const ADDITIONAL_CARDS_REQUIRED: int = 2
const EXPLOSION_DAMAGE: int = 20

func activate_card_effect() -> void:
	var fuse_status: Status = Status.get_status(PlayerManager.player_node, Status.Type.FUSE)
	var extra: int = 0
	if fuse_status:
		if fuse_status.stacks > 0:
			return
		
		if fuse_status.stacks == -1:
			# Restore the status
			extra = 1
	# Add 1 because one stack is immediately removed by this card
	Status.new(Status.Type.FUSE, ADDITIONAL_CARDS_REQUIRED + 1 + extra, PlayerManager.player_node)
