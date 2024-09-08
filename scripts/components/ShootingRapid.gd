extends TankComponent
class_name ShootingRapid

const component_name = "shoot"

var bullet_scene = Global.PRELOADS["bullet"]

@export_group("General")
@export var bullet_speed: int = 700
@export var bullet_damage: int = 10
@export var bullet_size: float = 0.5

@export_group("References")
@export var tank: Tank
@export var tank_sprite: Sprite2D
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
	if Input.is_action_pressed("shoot") and can_shoot and Global.no_console:
		can_shoot = false
		delay.start()
		
		if barrel == origin_left:
			barrel = origin_right
			animation = "shoot_left"
		elif barrel == origin_right:
			barrel = origin_left
			animation = "shoot_right"
		
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.global_position = barrel.global_position
		
		bullet_instance.set_stats(bullet_speed, bullet_damage, bullet_size)
		bullet_instance.set_velocity(tank_sprite.rotation_degrees - 90)
		bullet_instance.set_tank_owner(tank)

		tank.add_sibling(bullet_instance)
		
		if animation_player.is_playing():
			animation_player.stop()
		animation_player.play(animation)
		
		audio_player.pitch_scale = randf_range(0.8, 1)
		audio_player.play()

func _on_delay_timeout():
	can_shoot = true
