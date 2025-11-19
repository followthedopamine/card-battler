class_name LightFuse extends Card

const ADDITIONAL_CARDS_REQUIRED: int = 2
const EXPLOSION_DAMAGE: int = 20

func activate_card_effect() -> void:
	var fuse_status: Status = Status.get_status(PlayerManager.player_node, Status.Type.FUSE)
	if fuse_status:
		if fuse_status.stacks != 0:
			return
	# Add 1 because one stack is immediately removed by this card
	Status.new(Status.Type.FUSE, ADDITIONAL_CARDS_REQUIRED + 1, PlayerManager.player_node)
