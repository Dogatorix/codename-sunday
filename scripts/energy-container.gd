extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

@export var max_health: float 
@export var energy: int
@export var death_color: Color

@export var default_damp: float = 1.0 

var last_hit_by_bullet := false
var is_being_born := true

signal health_change(health: float)
signal death(energy)

var health = 20:
	set(value):
		health = max(0, value)
		health_change.emit(health)

var rotation_delta = randi_range(-45, 45)

func _ready():
	set_meta("can_be_dragged", true)
	set_gravity_scale(0)
	contact_monitor = true
	max_contacts_reported = 10
	health = max_health
	linear_damp = randi_range(1,7)
	animation_player.play("birth")

func _process(delta):
	sprite.rotation_degrees += rotation_delta * delta
 
func on_bullet_hit(bullet: BasicBullet):
	if not is_being_born:
		if animation_player.is_playing():
			animation_player.stop()
		animation_player.play("hit")
		
	last_hit_by_bullet = true
	
	health -= bullet.damage
	
	check_health()

func _on_body_entered(body):
	if not body.has_meta("is_bullet"):
		return
		
func check_health():
	if health == 0:
		if animation_player.is_playing():
			animation_player.stop()

		if last_hit_by_bullet:
			%DeathAudio.start()
		
		death.emit(energy, death_color)
		$Hitbox.queue_free()
		animation_player.play("death")

func apply_default_damp():
	linear_damp = default_damp
	is_being_born = false
