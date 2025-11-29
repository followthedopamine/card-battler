extends Node

const AMBIENT_LOOP: String = "res://card-battler-private/sfx/Cyberspace 011.wav"

const BUTTON_PRESSED_SFX: String = "UI Melodic Click 002"
const RELIC_PRESSED_SFX: String = "Targeted B"
const DAMAGE_SOUNDS: Array[String] = ["Weapon Obliterator 001", "Weapon Obliterator 007", "Weapon Pulse Gun 001"]
const PLAYER_HEALED_SFX: String = "Healed A"
const PLAYER_ADDED_BLOCK_SFX: String = "Clicking Mechanism Small F"
const RELIC_OFFERED_SFX: String = "Purged B"
const WAVE_END_SFX: String = "Vehicle ER-Unit 001 L to R"
const MONEY_SOUNDS: Array[String] = ["World Money Earned 001", "World Money Earned 002"]
const PACK_OPENED_SFX: String = "Gas Click A"
const LOSE_SFX: String = "Jingles Majestic Clavichord 004"
const CARD_PICKED_UP_SFX: String = "Menu Open"
const CARD_HOVERED_SFX: String = "Ratchet Short G"
const CARD_DROPPED_SFX: String = "Menu Close"

const VALID_AUDIO_EXTENSIONS: Array[String] = ["wav"]

const MAX_VOLUME_DB: float = 6
const MIN_VOLUME_DB: float = -32

const MAX_SOUNDS: int = 10

const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"

const AUDIO_FOLDER_PATH: String = "res://card-battler-private/sfx/"
var sounds: Dictionary[String, AudioStream]

@onready var sfx_bus_index: int = AudioServer.get_bus_index(SFX_BUS_NAME)
@onready var music_bus_index: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)

var sfx_pool: Array[AudioStreamPlayer2D]
var loops: Array[AudioStreamPlayer]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	SignalBus.sfx_volume_changed.connect(_on_sfx_volume_changed)
	SignalBus.music_volume_changed.connect(_on_music_volume_changed)
	
	SignalBus.button_pressed.connect(_on_button_pressed)
	SignalBus.relic_added.connect(_on_relic_added)
	SignalBus.player_dealt_damage.connect(_on_player_dealt_damage)
	SignalBus.player_healed.connect(_on_player_healed)
	SignalBus.player_added_block.connect(_on_player_added_block)
	SignalBus.relic_offered.connect(_on_relic_offered)
	SignalBus.wave_end.connect(_on_wave_end)
	SignalBus.enemy_dead.connect(_on_enemy_dead)
	SignalBus.pack_opened.connect(_on_pack_opened)
	SignalBus.lose.connect(_on_lose)
	SignalBus.card_sold.connect(_on_card_sold)
	# These sounds kinda suck
	#SignalBus.card_controller_picked_up.connect(_on_card_controller_picked_up)
	#SignalBus.card_controller_released.connect(_on_card_controller_released)
	SignalBus.card_controller_hovered.connect(_on_card_controller_hovered)
	
	var loop: AudioStreamPlayer = AudioStreamPlayer.new()
	loop.stream = load(AMBIENT_LOOP)
	loop.bus = SFX_BUS_NAME
	loop.finished.connect(_on_loop_finished.bind(loop))
	loop.volume_linear = 0.02
	self.add_child(loop)
	loop.play()
	loops.append(loop)
	for i: int in MAX_SOUNDS:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.bus = SFX_BUS_NAME
		player.finished.connect(return_to_pool.bind(player))
		self.add_child(player)
		sfx_pool.append(player)
	
		
	load_sound_dictionary()
	
func _on_loop_finished(player: AudioStreamPlayer) -> void:
	player.play()

func _on_button_pressed() -> void:
	play_sound(BUTTON_PRESSED_SFX, 0.03)
	
func _on_relic_added(_relid: Relic) -> void:
	play_sound(RELIC_PRESSED_SFX, 0.02)
	
func _on_player_dealt_damage() -> void:
	play_sound_random(DAMAGE_SOUNDS)
	
func _on_player_healed() -> void:
	play_sound(PLAYER_HEALED_SFX)
	
func _on_player_added_block() -> void:
	play_sound(PLAYER_ADDED_BLOCK_SFX)
	
func _on_relic_offered() -> void:
	play_sound(RELIC_OFFERED_SFX)
	
func _on_wave_end(_wave: int) -> void:
	play_sound(WAVE_END_SFX)

func _on_enemy_dead(_payout: int) -> void:
	play_sound_random(MONEY_SOUNDS)
	
func _on_pack_opened() -> void:
	play_sound(PACK_OPENED_SFX, 0.1)
	
func _on_lose() -> void:
	play_sound(LOSE_SFX)
	
func _on_card_controller_picked_up(_card_controller: CardController) -> void:
	play_sound(CARD_PICKED_UP_SFX, 0.05)
	
func _on_card_controller_released() -> void:
	play_sound(CARD_DROPPED_SFX, 0.05)
	
func _on_card_controller_hovered(_card_controller: CardController) -> void:
	play_sound(CARD_HOVERED_SFX, 0.1)
	
func _on_card_sold() -> void:
	play_sound_random(MONEY_SOUNDS)
	
func _on_sfx_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, value)
	
func _on_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, value)
	
func return_to_pool(player: AudioStreamPlayer2D) -> void:
	sfx_pool.append(player)
	
func load_sound_dictionary() -> void:
	var dir = DirAccess.open(AUDIO_FOLDER_PATH)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name:
			if !dir.current_is_dir() && file_name.get_extension() in VALID_AUDIO_EXTENSIONS:
				var full_path = AUDIO_FOLDER_PATH.path_join(file_name)
				var audio_stream: AudioStream = load(full_path)
				if audio_stream:
					sounds[file_name.get_basename()] = audio_stream

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access audio paths")
	
func get_player_from_pool() -> AudioStreamPlayer2D:
	#for player: AudioStreamPlayer2D in sfx_pool:
		#if !player.playing:
			#return player
	if sfx_pool.size():
		return sfx_pool.pop_front()
	return null
	
func get_audio_stream_by_name(sound_name: String) -> AudioStream:
	if sounds.has(sound_name):
		return sounds[sound_name]
	return null

# Default 0.02 for Ovani sounds
func play_sound(sound_name: String, from_position: float = 0.02) -> void:
	var player: AudioStreamPlayer2D = get_player_from_pool()
	if player == null:
		return
	var sound: AudioStream = get_audio_stream_by_name(sound_name)
	if sound == null:
		return
	player.stream = sound
	player.play(from_position)
	
func play_sound_random(sound_names: Array[String]) -> void:
	#print(sound_names.pick_random())
	play_sound(sound_names.pick_random(), 0.02)
