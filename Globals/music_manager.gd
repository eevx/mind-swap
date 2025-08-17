extends AudioStreamPlayer

@export var _theme_dictionary : Dictionary[String, AudioStream]

var _set_volume := 0.
var _beat_interval : float = 0.5
var _last_beat_index := 0

signal beat

func _ready() -> void:
	_beat_interval = GlobalVariables.TIME_STEP

func _process(_delta):
	var beat_index = int(floor(get_playback_position() / _beat_interval))
	if beat_index != _last_beat_index:
		_last_beat_index = beat_index
		beat.emit()

func play_theme(theme_name : String = "level theme", volume := 0.):
	if _theme_dictionary.has(theme_name):
		switch_track(_theme_dictionary[theme_name], volume)
		_set_volume = volume
		
func pause_theme(pause_volume := -20.):
	volume_db = pause_volume

func resume_theme():
	volume_db = _set_volume

func switch_track(track : AudioStream, volume := 0.):
	if stream == track:
		_set_volume = volume
		volume_db = volume
		return
	stream = track
	volume_db = volume
	set_playing(true)

func get_current_loudness() -> float:
	var bus_index = AudioServer.get_bus_index("Music")
	if bus_index == -1:
		return 0.0 

	var effect_instance = AudioServer.get_bus_effect_instance(bus_index, 0)
	if effect_instance == null:
		return 0.0 

	var rms = effect_instance.get_magnitude_for_frequency_range(20.0, 20000.0).length()
	return rms
