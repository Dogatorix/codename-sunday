extends TextureButton

var tween: Tween
@onready var original_scale := scale
@export var text_value: String
@export var is_button_disabled := false

func _ready():
	if is_button_disabled:
		disable()
	else:
		enable()
		
	$Label.text = text_value

func enable():
	mouse_default_cursor_shape = CursorShape.CURSOR_POINTING_HAND
	disabled = false
	$AnimationPlayer.stop()
	$AnimationPlayer.play("enable")
	
func disable():
	mouse_default_cursor_shape = CursorShape.CURSOR_ARROW
	disabled = true
	$AnimationPlayer.stop()
	$AnimationPlayer.play("disable")

func _on_button_down():
	if disabled:
		return
	
	scale = original_scale + Vector2(0.2, 0.2)
	
	$ClickSound.pitch_scale = 1 + randf_range(0.03, -0.03)
	$ClickSound.play()

	if tween:
		tween.kill()
		
	$AnimationPlayer.stop()
	$AnimationPlayer.play("press")
		
	tween = Global.tween(self, "scale", original_scale, 0.3, Tween.TransitionType.TRANS_CUBIC)
