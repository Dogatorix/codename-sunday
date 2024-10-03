extends AudioStreamPlayer2D
class_name Audio2D

@export var sounds: Array[AudioStream]
@export var pitch_range := 0.0
@export var external := false

var is_summoned := false

func start():
	if is_summoned:
		return
	
	var clone = self.duplicate()
	
	if external:
		clone.global_position = self.global_position
		get_parent().add_sibling(clone)
		clone.external = false
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
	
	var timer = Timer.new()
	timer.wait_time = stream.get_length()
	add_child(timer)
	timer.start()
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	
func _on_timer_timeout():
	queue_free()
