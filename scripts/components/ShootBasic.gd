extends TankComponent
class_name ShootBasic

const component_name = "shoot"

var bullet_scene = Global.PRELOADS["bullet"]

@export_group("General")
@export var bullet_speed: int = 700
@export var bullet_damage: int = 10
@export var bullet_size: float = 1
	
var can_shoot: bool = true

@export_group("References")
@export var tank: Tank
@export var animation_player: AnimationPlayer
@export var origin: Node2D
@export var tank_sprite: Sprite2D
@export var delay: Timer
@export var audio_player: AudioStreamPlayer2D

func _ready():
	if !tank:
		push_error(str(self) + " Neccesary nodes missing")
		queue_free()
		return
	set_meta("name", "shoot")
		
func on_process(_delta):
	if Input.is_action_pressed("shoot") and can_shoot and Global.no_console:
		can_shoot = false
		delay.start()
		
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.global_position = origin.global_position
		
		bullet_instance.set_stats(bullet_speed, bullet_damage, bullet_size)
		bullet_instance.set_velocity(tank_sprite.rotation_degrees - 90)
		bullet_instance.set_tank_owner(tank)
		
		tank.add_sibling(bullet_instance)
		
		if animation_player.is_playing():
			animation_player.stop()
				
		animation_player.play("shoot")
		audio_player.pitch_scale = randf_range(0.9, 1)
		audio_player.play()
	
func _on_delay_timeout():
	can_shoot = true
