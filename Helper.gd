extends Node

func play_external_sound(source, audio_stream: AudioStream, volume: float = 1.0):
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = audio_stream
	audio_player.volume_db = volume

	var timer = Timer.new()
	timer.wait_time = audio_stream.get_length()

	timer.connect("timeout", Callable(self, "_on_sound_finished").bind(audio_player))
	timer.autostart = true
	timer.one_shot = true
	
	audio_player.add_child(timer)
	
	source.add_sibling(audio_player)
	audio_player.play()

func _on_sound_finished(audio_player: AudioStreamPlayer2D):
	audio_player.queue_free()
