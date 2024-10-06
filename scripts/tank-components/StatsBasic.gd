extends TankComponent
class_name StatsBasic

const component_name = "stats"

const CORE_REQUIREMENT = {
	1: 500,
	2: 2000,
	3: 8000,
	4: 16000
}

@export_group("General")
@export var max_health = 100
@export var max_rust = 100
@export var max_mana = 100
@export var mana_regeneration_rate := 20.0

@export_group("References")
@export var animation_player: AnimationPlayer
@export var damage_sounds: Audio2D
@export var damage_particle: Particle2D

var max_core_points := 1000

signal health_change(value)
signal rust_change(value)
signal mana_change(value)
signal points_change(value) 
signal on_damaged(amount)

@onready var health = max_health
@onready var mana = max_mana
var rust = 0
var points = 0

func _ready():	
	max_core_points = CORE_REQUIREMENT[tank.core_tier]

func on_process(_delta):
	if Input.is_action_just_pressed("debug"):
		damage_tank(20)

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
	set_health(health - abs(amount))
	
	if health == 0:
		return
	
	if animation_player:
		animation_player.play("damage")
	if damage_sounds:
		damage_sounds.start()
	if damage_particle:
		damage_particle.start()
		
func _process(delta):
	mana = min(100, mana + mana_regeneration_rate * delta)
