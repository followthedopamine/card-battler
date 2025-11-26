extends Node

const VALID_AUDIO_EXTENSIONS: Array[String] = ["wav"]

const MAX_VOLUME_DB: float = 6
const MIN_VOLUME_DB: float = -32

const MAX_SOUNDS: int = 10

const MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"

const AUDIO_FOLDER_PATH: String = "res://assets/audio/"
var sounds: Dictionary[String, AudioStream]

@onready var sfx_bus_index: int = AudioServer.get_bus_index(SFX_BUS_NAME)
@onready var music_bus_index: int = AudioServer.get_bus_index(MUSIC_BUS_NAME)

var sfx_pool: Array[AudioStreamPlayer2D]

func _ready() -> void:
	SignalBus.sfx_volume_changed.connect(_on_sfx_volume_changed)
	SignalBus.music_volume_changed.connect(_on_music_volume_changed)
	
	for i: int in MAX_SOUNDS:
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.bus = SFX_BUS_NAME
		self.add_child(player)
		sfx_pool.append(player)
		
	load_sound_dictionary()
	
	# Uncomment for testing
	#play_sound("synth_loop")
	
func _on_sfx_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_bus_index, value)
	
func _on_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus_index, value)
	
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
	for player: AudioStreamPlayer2D in sfx_pool:
		if !player.playing:
			return player
	return null
	
func get_audio_stream_by_name(sound_name: String) -> AudioStream:
	if sounds.has(sound_name):
		return sounds[sound_name]
	return null
	
func play_sound(sound_name: String, from_position: float = 0.0) -> void:
	var player: AudioStreamPlayer2D = get_player_from_pool()
	if player == null:
		return
	var sound: AudioStream = get_audio_stream_by_name(sound_name)
	if sound == null:
		return
	player.stream = sound
	player.play(from_position)
