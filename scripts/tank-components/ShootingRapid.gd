extends ShootPreIndustrial
class_name ShootingRapid

const component_name = "shoot"

@export_group("References")
@export var tank_sprite: Node2D
@export var animation_player: AnimationPlayer
@export var origin_left: Node2D
@export var origin_right: Node2D
@export var delay: Timer
@export var audio_player: AudioStreamPlayer2D

var can_shoot := true
var barrel: Node2D
var animation := "shoot_left"

func _ready():
	barrel = origin_left

func on_process(_delta):
	if Input.is_action_pressed("shoot") and can_shoot and Global.active_input \
	and tank.is_client and not prevent_shoot:
		can_shoot = false
		delay.start()
		
		if barrel == origin_left:
			barrel = origin_right
			animation = "shoot_left"
		elif barrel == origin_right:
			barrel = origin_left
			animation = "shoot_right"
		
		summon_bullet(barrel.global_position)
		
		if animation_player.is_playing():
			animation_player.stop()
		animation_player.play(animation)
		
		audio_player.start()

func _on_delay_timeout():
	can_shoot = true
