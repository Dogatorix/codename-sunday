extends TankComponent
class_name DashBasic

const component_name = "dash"

@export_group("General")
@export var dash_strength := 3000
@export var dash_consumption := 20

@export_group("References")
@export var tank: Tank
@export var movement: MovementBasic
@export var tank_stats: StatsBasic
@export var dash_sounds: Array[AudioStream]
@export var dash_shake: Shake2D

func _ready():
	if not movement or not tank:
		push_error(str(self) + "Neccesary nodes missing!")
		queue_free()
		return

func on_process(_delta):
	if Input.is_action_just_pressed("special_move") and tank_stats and Global.no_console:
		if tank_stats.mana > dash_consumption:
			tank_stats.set_mana(tank_stats.mana - dash_consumption)
		
			Helper.play_external_sound(tank, dash_sounds.pick_random(), -3)	
			
			movement.velocity = Vector2.ZERO
			var dash_velocity = movement.input_vector * (dash_strength + (movement.speed * 2)) / 90
			movement.dash_velocity = dash_velocity
			
			dash_shake.start()
		
	movement.dash_velocity /= 30
	dash_shake.global_position = tank.global_position
