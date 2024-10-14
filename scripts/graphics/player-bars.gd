extends Control

@export var stats: StatsBasic

var health_opacity := 0.0
var mana_opacity := 0.0

var health_percent: float:
	get:
		@warning_ignore("integer_division")
		return (stats.health * 100) / stats.max_health

var mana_percent: float:
	get:
		@warning_ignore("integer_division")
		return (stats.mana * 100) / stats.max_mana

var smooth_health := 0.0
var smooth_mana := 0.0

func _ready():
	stats.connect("health_change", _on_health_change)
	stats.connect("mana_change", _on_mana_change)

func _process(delta):
	@warning_ignore("integer_division")
	%HealthBar.value = (stats.health * 100) / stats.max_health
	@warning_ignore("integer_division")
	%ManaBar.value = (stats.mana * 100) / stats.max_mana
	
	health_opacity = max(0, health_opacity - (delta * 2))
	mana_opacity = max(0, mana_opacity - (delta * 2))
	
	%HealthBar.modulate.a = health_opacity
	%HealthBarUnder.modulate.a = health_opacity
	%ManaBar.modulate.a = mana_opacity
	%ManaBarUnder.modulate.a = mana_opacity
	
	smooth_health += ((health_percent - smooth_health) / 10) * delta * 80
	smooth_mana += ((mana_percent - smooth_mana) / 10) * delta * 30
	
	%HealthBarUnder.value = smooth_health
	%ManaBarUnder.value = smooth_mana

func _on_health_change(_value):	
	health_opacity = 1.5
	
func _on_mana_change(_value):
	mana_opacity = 1.5
