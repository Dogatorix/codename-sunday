extends TankBehaviourComponent
class_name StatsBasic

const CORE_REQUIREMENT = {
	Enums.TANK_TIERS.BASIC: 250,
	Enums.TANK_TIERS.STARTER: 1000,
	Enums.TANK_TIERS.INDUSTRIAL: 8000,
}

@export var core_tier: Enums.TANK_TIERS

@export var max_health = 100
@export var max_rust = 100
@export var max_mana = 100
@export var mana_regeneration_rate := 20.0
@export var health_regeneration_rate := 20.0
@export var health_regeneration_delay := 4.5

@onready var sprite_animations: AnimationPlayer = %SpriteAnimations
@onready var damage_sounds: Audio2D = %HurtSound
@onready var damage_particle: Particle2D = %DamageParticle

var max_core_points := 1000

signal health_change(value)
signal rust_change(value)
signal mana_change(value)
signal points_change(value) 
signal on_damaged(amount)
signal max_points()

@onready var health = max_health
@onready var mana = max_mana
var rust = 0
var points = 0

@onready var regen_delay := health_regeneration_delay
var reached_max_points := false

var time := 0.0

var is_immune: bool:
	get:
		return time <= 2.5

func _setup_finished():
	tank.stats_setup_finished.emit()
	
	max_core_points = CORE_REQUIREMENT[core_tier]
	
	if tank.is_spawning:
		sprite_animations.play("respawn")
	
	tank.player_bars.stats = self
	tank.player_bars.on_ready()

func _process(delta):
	time += delta
	regen_delay -= delta
	
	if regen_delay <= 0:
		health = min(max_health, health + (delta * health_regeneration_rate))
		
	mana = min(100, mana + mana_regeneration_rate * delta)
	tank.player_bars.on_process(delta)
	
	if Input.is_action_just_pressed("debug") and tank.is_client:
		points = max_core_points
	
	if not reached_max_points and points >= max_core_points:
		reached_max_points = true
		max_points.emit()
		
func set_health(value):
	health = clamp(value, 0, max_health)
	health_change.emit(value)
	
func set_rust(value):
	rust = clamp(value, 0, max_rust)
	rust_change.emit(value)
	
func set_mana(value):
	mana = clamp(value, 0, max_mana)
	mana_change.emit(value)
	
func set_points(value):
	points = clamp(value, 0, max_core_points)
	points_change.emit(value)

func damage_tank(amount):
	if tank.is_client and Settings.client_god_mode:
		amount = 0
	
	if is_immune:
		set_health(health - abs(amount / 4))
	else:
		set_health(health - abs(amount))
		
	regen_delay = health_regeneration_delay
	
	if health <= 0:
		return
	
	if tank.is_client:
		Global.Game.Overlay.damage()
	sprite_animations.play("damage")
	damage_sounds.start()
	damage_particle.start()
