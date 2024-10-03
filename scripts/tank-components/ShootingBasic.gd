extends ShootPreIndustrial
class_name ShootBasic

const component_name = "shoot"
	
var can_shoot: bool = true

@export_group("References")
@export var animation_player: AnimationPlayer
@export var origin: Node2D
@export var tank_sprite: Node2D
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
		
		summon_bullet(origin.global_position)

		if animation_player.is_playing():
			animation_player.stop()
		
		animation_player.play("shoot")
		audio_player.start()
	
func _on_delay_timeout():
	can_shoot = true
