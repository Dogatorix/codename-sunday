extends Node2D

enum CONTAINER_TYPE {
	SQUARE,
	TRIANGLE,
	PENTAGON,
	OCTAGON
}

@export var container: PackedScene

var max_energy_power := 30
var max_payload_cooldown := 180
var payload_cooldown := 0

@export var payload_power := 15
@onready var energy_power := max_energy_power:
	set(value):
		if value == 0:
			timer_conditional()
		energy_power = value

@export var animation_player: AnimationPlayer
@export var display_text: Label

func _ready():
	display_text.text = str(energy_power)
	
	var degrees_offset = (floor(rotation_degrees / 90)) * -90
	display_text.rotation_degrees = degrees_offset

func _on_payload_timer_timeout():
	if energy_power > 0 and payload_cooldown <= 0:
		$PayloadTimer.start()
		
	if payload_power <= 0 or randi_range(0,10) <= 3:
		return
		
	var spawn_seed = randi_range(0, 100)
	
	if spawn_seed < 60:
		for i in range(randi_range(3,6)):
			var container_variants = [CONTAINER_TYPE.SQUARE, CONTAINER_TYPE.TRIANGLE]
			spawn_container(container_variants.pick_random())
	elif spawn_seed < 80:
		for i in range(randi_range(1,2)):
			spawn_container(CONTAINER_TYPE.PENTAGON)
	else:
		spawn_container(CONTAINER_TYPE.OCTAGON)
		
	if energy_power > 0:
		animation_player.play("dispense")
		%ShootAudio.start()
	else:
		%RechargeAudio.start()
		animation_player.play("timer_start")
		
	display_text.text = str(energy_power)
		
func _on_cooldown_timer_timeout():
	if payload_cooldown > 0:
		payload_cooldown -= 1
		display_text.text = seconds_to_clock(payload_cooldown)
		$CooldownTimer.start()
		%TickAudio.start()
	else:
		$CooldownTimer.stop()
		animation_player.play("timer_stop")
		energy_power = max_energy_power
		display_text.text = str(energy_power)
		$PayloadTimer.start()
	
func spawn_container(type: CONTAINER_TYPE):
	if (energy_power <= 0 and payload_cooldown <= 0):
		timer_conditional()
		return
	
	if (payload_power <= 0 or energy_power <= 0):
		return
		
	payload_power -= 1
	energy_power -= 1
	
	var velocity_vector = Vector2(randi_range(700,1500), randi_range(-500, 500)).rotated(deg_to_rad(rotation_degrees))
	var container_instance = container.instantiate()
	
	container_instance.container_type = type
	container_instance.global_position = global_position
	container_instance.container_velocity_init = velocity_vector
	container_instance.dispenser_owner = self
	
	add_sibling(container_instance)

func seconds_to_clock(seconds):
	var minutes = floor(seconds / 60)
	
	var second_string = ""
	if (seconds % 60 < 10):
		second_string += "0" 
	second_string += str(seconds % 60)


	return str(minutes) + ":" + second_string

func timer_conditional():
	payload_cooldown = max_payload_cooldown
	$CooldownTimer.start()
	$PayloadTimer.stop()
	%CloseAudio.start()
	%ShootAudio.start()
	
	if animation_player.is_playing():
		animation_player.stop()		
