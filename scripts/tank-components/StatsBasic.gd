extends TankBehaviourComponent
class_name StatsBasic

const component_name = "stats"

@onready var tank: Tank = data_node.tank

const CORE_REQUIREMENT = {
	Enums.TANK_TIERS.BASIC: 300,
	Enums.TANK_TIERS.STARTER: 2000,
	Enums.TANK_TIERS.INDUSTRIAL: 8000,
}

@export var core_tier: Enums.TANK_TIERS
@export var upgrades: Array[Enums.TANKS]

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

# this is cancer, please fix in 1.3
@export var respawn_animation: AnimationPlayer

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

func on_ready():
	max_core_points = CORE_REQUIREMENT[core_tier]
	
	if tank.is_spawning:
		respawn_animation.play("respawn")
	
	tank.player_bars.stats = self
	tank.player_bars.on_ready()
	tank.connect("on_upgrade_tank", tank_upgrade_init)
	
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
	time += delta
	var player_interface = Global.Game.player_interface
	
	if player_interface != null:
		if player_interface.stats == self:
			player_interface.on_process(delta)
	
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
		var shoot_component = tank.behaviour("shoot")
		shoot_component.disable_shoot()
		
		if tank.is_client:
			Global.Game.add_upgrade_menu(upgrades, 2)
			%UpgradeShake.start()
			%UpgradeSound.start()
		
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
	if is_immune:
		set_health(health - abs(amount / 4))
	else:
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

var upgrade_id: Enums.TANKS = Enums.TANKS.BASIC

func tank_upgrade_init(tank_id: Enums.TANKS):
	upgrade_id = tank_id
	tank_animations.play("retract")
	
func tank_upgrade_post():
	tank.switch_tank_scene(upgrade_id)
