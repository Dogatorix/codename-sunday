extends CanvasLayer

@export var animation_player: AnimationPlayer

var is_bars_shown := false

func show_bars():
	if not is_bars_shown:
		animation_player.play("bar-open")
		is_bars_shown = true
	
func hide_bars():
	if is_bars_shown:
		animation_player.play("bar-close")
		is_bars_shown = false
