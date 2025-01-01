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
@export var burnout_particle: Particle2D

var bullet_velocity: Vector2
var collision_body: CollisionObject2D

func _ready():	
	scale = Vector2(size,size)
	bullet_sprite.rotation_degrees = direction
	bullet_velocity = Vector2(1,0).rotated(deg_to_rad(direction)) * speed
	modulate = color
	scale = Vector2(size, size)
	
func _process(delta):
	global_position += bullet_velocity * delta

func _on_body_entered(body):	
	if body is BasicBullet or body == tank:
		return
		
	if body is Tank:
		collision_body = body
	
	if body is Tank:
		var tank_stats: StatsBasic = body.behaviour(Enums.COMPONENTS.STATS)
		tank_stats.damage_tank(damage)
	else:	
		audio_player.start()
	
	
	if body.has_meta("bullet_target"):
		body.on_bullet_hit(self)
		damage_bullet()
	else:
		kill_bullet()

func summon_particle():
	if collision_body is Tank:
		return
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
	burnout_particle.start()
	queue_free()
