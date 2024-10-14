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
