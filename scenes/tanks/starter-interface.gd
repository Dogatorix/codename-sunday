extends CanvasLayer

@export var animation_player: AnimationPlayer

@onready var tank = Global.Game.client
var stats: StatsBasic

var health_percent := 100.0
var rust_percent := 0.0
var mana_percent := 100.0
var points_percent := 0.0

var is_dying := false

@onready var smooth_health: = health_percent
@onready var smooth_rust := rust_percent
@onready var smooth_mana := mana_percent
@onready var smooth_points_left: int	
@onready var smooth_core := 0.0

func on_ready():
	visible = true
	if not stats:
		push_error(str(self) + " Missing reference to stats component")
		queue_free()
	
	%ManaBar.value = mana_percent
	%HealthBar.value = health_percent
	%CoreBar.value = points_percent
	
	%TankName.text = tank.username
	
	%CoreBar.tint_progress = tank.tank_color
	%PointsLeft.modulate = tank.tank_color
	%TankName.modulate = tank.tank_color

var time := 0.0
func on_process(delta):
	time += delta
	
	health_percent = stats.health * 100 / float(stats.max_health)
	%HealthBar.value = max(health_percent, 0.1)
	
	smooth_health += ((health_percent - smooth_health) / 10) * delta * 70
	%HealthBarOffset.value = smooth_health

	_on_mana_change(stats.mana)
	smooth_mana += ((mana_percent - smooth_mana) / 10) * delta * 70
	%ManaBarOffset.value = smooth_mana
	
	smooth_mana += ((mana_percent - smooth_mana) / 10) * delta * 70
	
	smooth_core += ((points_percent - smooth_core) / 10) * delta * 70
	%CoreBar.value = smooth_core
	
	points_percent = stats.points * 100 / float(stats.max_core_points)
	
	var points_left = stats.max_core_points - stats.points
	smooth_points_left += (points_left - smooth_points_left) / (150 * delta)
	%PointsLeft.text = str(smooth_points_left) + " XP LEFT"
	
	%CoreBar.tint_progress.a = max(abs(sin(time * 3)), 0.75)
	
	if stats.health <= 0 and not is_dying:
		on_death()
	
	######
	
	%CoreBar.tint_progress = tank.tank_color
	%PointsLeft.modulate = tank.tank_color
	%TankName.modulate = tank.tank_color
	
func _on_mana_change(value):
	mana_percent = value * 100 / stats.max_mana
	%ManaBar.value = mana_percent

func on_death():
	is_dying = true	
	animation_player.play("hide")
