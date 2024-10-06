extends Area2D
class_name BasicBullet
	
###Changed by summoner

var tank: Tank

var speed := 500.0
var direction := 0.0
var size := 1.0
var color: Color
var damage := 0.0

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
	
	if body.has_meta("bullet_target"):
		body.on_bullet_hit(self)
		
	on_death()

func on_death():
	var particle_instance = particle_scene.instantiate()
	particle_instance.position = position
	add_sibling(particle_instance)
	queue_free()
	
func _on_timer_timeout():
	queue_free()
