extends ShootPreIndustrial
class_name ShootBasic

@export var knockback = 0.0

@export var tank_animations: AnimationPlayer
@export var origin: Node2D
@export var shoot_sound: AudioStreamPlayer2D
		
@export var delay: Timer

var movement: MovementBasic
var dash: DashBasic

func _setup_finished():
	%TransitionSound.start()
	
	movement = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	dash = tank.behaviour(Enums.COMPONENTS.DASH)
	
	await tank_animations.animation_finished
	enable_shoot()
	
func _process(_delta):
	if get_shoot_condition():
		can_shoot = false
		delay.start()
		
		summon_bullet(origin.global_position)
		
		if tank_animations:
			tank_animations.stop()
			tank_animations.play("shoot")
			
		shoot_sound.start()
		
		var tank_rotation = sprite_node.rotation_degrees + 90
		
		if knockback > 0:
			movement.apply_external_velocity(tank_rotation, knockback, 1000)
			dash.dash_length -= knockback
			
func _on_delay_timeout():
	can_shoot = true
