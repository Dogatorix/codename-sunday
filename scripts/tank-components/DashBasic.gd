extends TankComponent
class_name DashBasic

const component_name = "dash"

@export_group("General")
@export var dash_strength := 3000
@export var dash_consumption := 20

@export_group("References")
@export var movement: MovementBasic
@export var tank_stats: StatsBasic
@export var audio_player: Audio2D
@export var dash_shake: Shake2D
@export var dash_shockwave: Shockwave

func _ready():
	safety_check([movement])

func on_process(_delta):
	if Input.is_action_just_pressed("special_move") and tank_stats \
	and movement.input_vector and Global.no_console:
		if tank_stats.mana > dash_consumption:
			tank_stats.set_mana(tank_stats.mana - dash_consumption)
			
			movement.velocity = Vector2.ZERO
			var dash_velocity = movement.input_vector * (dash_strength + (movement.speed * 2)) / 90
			movement.dash_velocity = dash_velocity
			
			audio_player.start()
			dash_shake.start()
			var shockwave_clone: Shockwave = dash_shockwave.duplicate()
			tank.add_sibling(shockwave_clone)
			shockwave_clone.start()
			shockwave_clone.global_position = tank.global_position
			
	movement.dash_velocity /= 30
	dash_shake.global_position = tank.global_position
