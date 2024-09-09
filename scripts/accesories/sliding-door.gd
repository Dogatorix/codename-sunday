extends Node2D

@export var animation_player: AnimationPlayer
@export var audio_player: AudioStreamPlayer2D
@export var open_sound: AudioStream
@export var close_sound: AudioStream

var is_open := false
var can_close := false

var close_delay_max := 40.0
var close_delay := 0.0

func _process(delta):
	close_delay = max(0, close_delay - (delta * 100))
	
	if can_close and close_delay <= 0:
		animation_player.play("close")
		audio_player.stream = close_sound
		audio_player.play()
		can_close = false
		is_open = false
	
func _on_area_2d_body_entered(body):
	if not body is CharacterBody2D or is_open:
		return
	
	animation_player.play("open")
	audio_player.stream = open_sound
	audio_player.play()
	is_open = true
	can_close = false
	close_delay = close_delay_max
	
func _on_area_2d_body_exited(body):
	if not body is CharacterBody2D or not is_open:
		return
		
	can_close = true
	close_delay = close_delay_max
