extends ShootPreIndustrial
class_name ShootingRapid

@export var tank_sprite: Node2D
@export var tank_animations: AnimationPlayer
@export var origin_left: Node2D
@export var origin_right: Node2D
@export var delay: Timer
@export var audio_player: AudioStreamPlayer2D

var barrel: Node2D
var animation := "shoot_left"

func _setup_finished():
	%TransitionSound.start()
	
	barrel = origin_left
	
	await tank_animations.animation_finished
	enable_shoot()

func ai_shoot():
	if get_ai_shoot_condition():
		_shoot_bullet()

func _process(_delta):
	if get_shoot_condition():
		_shoot_bullet()
	
func _shoot_bullet():
	can_shoot = false
	delay.start()
	
	if barrel == origin_left:
		barrel = origin_right
		animation = "shoot_left"
	elif barrel == origin_right:
		barrel = origin_left
		animation = "shoot_right"
	
	summon_bullet(barrel.global_position)
	
	if tank_animations.is_playing():
		tank_animations.stop()
	tank_animations.play(animation)
	
	audio_player.start()

func _on_delay_timeout():
	can_shoot = true
