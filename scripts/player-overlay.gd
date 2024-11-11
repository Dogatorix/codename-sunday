extends CanvasLayer

@export var bar_animations: AnimationPlayer
@export var overlay_animations: AnimationPlayer

var is_bars_shown := false

func show_bars():
	if not is_bars_shown:
		bar_animations.play("bar-open")
		is_bars_shown = true
	
func hide_bars():
	if is_bars_shown:
		bar_animations.play("bar-close")
		is_bars_shown = false

func damage():
	overlay_animations.stop()
	overlay_animations.play("damage")

func _process(_delta):
	%FPS.text = "FPS:" + str(Engine.get_frames_per_second())
	var memory_usage = OS.get_static_memory_usage() / 1000000.0
	%Memory.text = "Memory: " + str(int(memory_usage)) + "MB"
