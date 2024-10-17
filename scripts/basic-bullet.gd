extends Area2D
class_name BasicBullet
	
###Changed by summoner

var tank: Tank

var speed := 500.0
var damage := 0.0
var size := 1.0
var penetration := 1

var direction := 0.0
var color: Color

###

@export var particle_scene: PackedScene 
@export var audio_player: Audio2D
@export var bullet_sprite: Sprite2D

var bullet_velocity: Vector2

func _ready():	
	scale = Vector2(size,size)
	bullet_sprite.rotation_degrees = direction
	bullet_velocity = Vector2(1,0).rotated(deg_to_rad(direction)) * speed
	modulate = color
	scale = Vector2(size, size)
	
func _process(delta):
	global_position += bullet_velocity * delta

func _on_body_entered(body):
	if body is BasicBullet:
		return
		
	audio_player.start()
	
	summon_particle()
	if body.has_meta("bullet_target"):
		body.on_bullet_hit(self)
		damage_bullet()
	else:
		kill_bullet()
		

func summon_particle():
	var particle_instance = particle_scene.instantiate()
	particle_instance.position = position
	add_sibling(particle_instance)

func damage_bullet():
	penetration -= 1
	if penetration <= 0:
		summon_particle()
		kill_bullet()
		
func kill_bullet():
	summon_particle()
	queue_free()

func _on_timer_timeout():
	queue_free()
