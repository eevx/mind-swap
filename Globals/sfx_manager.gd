extends Node2D

@export var sfx_dict : Dictionary[String, AudioStream]
@export var audio_player : PackedScene

func play_sfx(audio_name : String, volume := 0., pitch := 1.):
	if not sfx_dict.has(audio_name):
		push_warning("no audio called " + audio_name)
		return
	if not audio_player.can_instantiate():
		return
	
	var new_audio_player : AudioPlayerOneshot = audio_player.instantiate()
	new_audio_player.stream = sfx_dict[audio_name]
	new_audio_player.volume_db = volume
	new_audio_player.pitch_scale = pitch
	add_child(new_audio_player)
