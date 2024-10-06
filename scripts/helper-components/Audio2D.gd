extends AudioStreamPlayer2D
class_name Audio2D

@export var sounds: Array[AudioStream]
@export var pitch_range := 0.0
@export var external := false

var is_summoned := false

func start():
	if is_summoned:
		return
	
	var clone: Audio2D = self.duplicate()
	
	if external:
		get_parent().add_sibling(clone)
		clone.global_position = self.global_position
		clone.is_summoned = true
		clone.external = false
		clone.play_sound()
	else:
		add_sibling(clone)
		
	clone.is_summoned = true
	clone.play_sound()
	
func play_sound():
	if not is_summoned:
		return
	
	if sounds:
		stream = sounds.pick_random()
	pitch_scale += randf_range(-pitch_range, pitch_range)
	play()
	
	Global.timeout_destroy(self, stream.get_length())
