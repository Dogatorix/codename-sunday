extends ShootPreIndustrial
class_name ShootBasic

const component_name = "shoot"

var can_shoot: bool = true

@export var knockback = 0.0
@export var dash: DashBasic

@export_group("References")
@export var animation_player: AnimationPlayer
@export var origin: Node2D
@export var tank_sprite: Node2D
@export var delay: Timer
@export var audio_player: AudioStreamPlayer2D
@export var movement: MovementBasic
		
func on_process(_delta):
	if Input.is_action_pressed("shoot") and can_shoot \
	and Global.active_input and tank.is_client and not prevent_shoot:
		can_shoot = false
		delay.start()
		
		summon_bullet(origin.global_position)
		
		if animation_player:
			animation_player.stop()
			animation_player.play("shoot")
			
		audio_player.start()
		
		var tank_rotation = movement.tank_sprite.rotation_degrees + 90
		
		if knockback > 0:
			movement.apply_external_velocity(tank_rotation, knockback, 1000)
			dash.dash_length -= knockback
			
func _on_delay_timeout():
	can_shoot = true
