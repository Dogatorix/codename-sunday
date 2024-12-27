extends TankBehaviourComponent
class_name StatsBasic

const component_name = "stats"

@onready var tank: Tank = data_node.tank

enum TIERS {
	BASIC = 1,
	STARTER = 2,
	INDUSTRIAL = 3,
	PIONEER = 4,
}

const CORE_REQUIREMENT = {
	1: 500,
	2: 2000,
	3: 8000,
	4: 16000
}

@export var core_tier: TIERS

@export_group("General")
@export var max_health = 100
@export var max_rust = 100
@export var max_mana = 100
@export var mana_regeneration_rate := 20.0
@export var health_regeneration_rate := 20.0
@export var health_regeneration_delay := 4.5

@export_group("References")
@export var animation_player: AnimationPlayer
@export var tank_animations: AnimationPlayer
@export var damage_sounds: Audio2D
@export var damage_particle: Particle2D
@export var colored_nodes: Array[Node]

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

func on_ready():	
	max_core_points = CORE_REQUIREMENT[core_tier + 1]
	
	tank.player_bars.stats = self
	tank.player_bars.on_ready()
	tank.connect("upgrade_tank", tank_upgrade_init)
	
	for node in colored_nodes:
		node.modulate = tank.tank_color

	if tank.is_client and Global.Game.player_interface != null:
		Global.Game.player_interface.stats = self
		Global.Game.player_interface.on_ready()

	if tank.is_client and not Global.Game.player_interface:
		await Global.Game.add_player_interface()
		Global.Game.player_interface.stats = self
		Global.Game.player_interface.on_ready()

func on_process(delta):
	var player_interface = Global.Game.player_interface
	
	if player_interface != null:
		if player_interface.stats == self:
			player_interface.on_process(delta)
	
	regen_delay -= delta
	
	if regen_delay <= 0:
		health = min(max_health, health + (delta * health_regeneration_rate))
		
	mana = min(100, mana + mana_regeneration_rate * delta)
	tank.player_bars.on_process(delta)

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
	regen_delay = health_regeneration_delay
	
	if health == 0:
		return
	
	if tank.is_client:
		Global.Game.Overlay.damage()
	if animation_player:
		animation_player.play("damage")
	if damage_sounds:
		damage_sounds.start()
	if damage_particle:
		damage_particle.start()

var upgrade_id := 0

func tank_upgrade_init(tank_id):
	upgrade_id = tank_id
	tank_animations.play("retract")
	
func tank_upgrade_post():
	tank.switch_tank_scene(upgrade_id)
