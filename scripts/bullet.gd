extends RigidBody2D

var bullet_speed
var bullet_damage
var bullet_size

var particle_scene = load("res://scenes/tanks/bullet-death-particle.tscn")

var owner_node: CharacterBody2D

@export var wall_sounds: Array[AudioStream]
@export var audio_player: Audio2D

func _ready():
	set_gravity_scale(0)
	contact_monitor = true
	max_contacts_reported = 1
	
func set_velocity(direction: float):
	linear_velocity = Vector2(1,0).rotated(deg_to_rad(direction)) * bullet_speed

func _on_timer_timeout():
	queue_free()

func on_death():
	var particle_instance = particle_scene.instantiate()
	particle_instance.position = position
	add_sibling(particle_instance)
	queue_free()
	
func set_tank_owner(tank: CharacterBody2D):
	owner_node = tank

func set_stats(speed, damage, size):
	bullet_speed = speed
	bullet_damage = damage
	bullet_size = size

func _on_body_entered(body):
	if body.has_meta("is_bullet"):
		return
		
	audio_player.start()
	
	if not body.has_meta("is_container"):
		on_death()
