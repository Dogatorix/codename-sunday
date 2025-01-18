extends TankBehaviourComponent
class_name DashBasic

@export var dash_strength := 1200
@export var dash_consumption := 30

var movement: MovementBasic
var tank_stats: StatsBasic

@onready var audio_player: Audio2D = %DashSounds
@onready var dash_shockwave: Shockwave = %DashShockwave

var dash_velocity := Vector2.ZERO
@onready var dash_decay := float(dash_strength) * 2
var dash_length := 0.0

func _setup_finished():
	movement = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	tank_stats = tank.behaviour(Enums.COMPONENTS.STATS)

func ai_dash():
	tank_stats.set_mana(tank_stats.mana - dash_consumption)
			
	movement.normal_velocity = Vector2.ZERO
	movement.reset_external_velocity()
	
	dash_velocity = movement.input_vector.normalized() * (dash_strength)
	dash_length = dash_velocity.length()	
		
	audio_player.start()
	var shockwave_clone: Shockwave = dash_shockwave.duplicate()
	tank.add_sibling(shockwave_clone)
	shockwave_clone.start()
	shockwave_clone.global_position = tank.global_position

func _process(delta):
	if Input.is_action_just_pressed("special_move") and tank_stats \
	and movement.input_vector and Global.Game.input_autherization(tank) and tank.is_client:
		if tank_stats.mana > dash_consumption:
			tank_stats.set_mana(tank_stats.mana - dash_consumption)
			
			movement.normal_velocity = Vector2.ZERO
			movement.reset_external_velocity()
			
			dash_velocity = movement.input_vector.normalized() * (dash_strength)
			dash_length = dash_velocity.length()	
				
			audio_player.start()
			var shockwave_clone: Shockwave = dash_shockwave.duplicate()
			tank.add_sibling(shockwave_clone)
			shockwave_clone.start()
			shockwave_clone.global_position = tank.global_position
	
	dash_length = max(0, dash_length - (dash_decay * delta))
	dash_velocity = dash_velocity.normalized() * dash_length
	
	movement.dash_velocity = dash_velocity
