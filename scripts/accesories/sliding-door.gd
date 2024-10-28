extends Node2D

@export var animation_player: AnimationPlayer
@export var audio_player: AudioStreamPlayer2D
@export var open_sound: AudioStream
@export var close_sound: AudioStream

@export var open_region: Area2D

var is_open := false

func close_door():
	is_open = false
	animation_player.play("close")
	audio_player.stream = close_sound
	audio_player.play()
	
func open_door():
	is_open = true
	animation_player.play("open")
	audio_player.stream = open_sound
	audio_player.play()

func _on_enter(body):
	if not body is Tank or is_open:
		return
	open_door()

func _on_exited(body):
	if not body is Tank or not is_open:
		return
	
	var has_player := false
	for node in open_region.get_overlapping_bodies():
		if node is Tank:
			has_player = true
			break
	
	if has_player:
		return
		
	close_door()
