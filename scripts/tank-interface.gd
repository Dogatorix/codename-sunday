extends Control

@export var stats: StatsBasic
@export var animation_player: AnimationPlayer

var health_percent := 100.0
var rust_percent := 0.0
var mana_percent := 100.0
var points_percent := 0.0
 
@onready var smooth_health: = health_percent
@onready var smooth_rust := rust_percent
@onready var smooth_mana := mana_percent
@onready var smooth_points_left: int

func _ready():
	if not stats:
		push_error(str(self) + " Missing reference to stats component")
		queue_free()
	
	stats.connect("health_change", Callable(self, "_on_health_change"))
	stats.connect("rust_change", Callable(self, "_on_rust_change"))
	stats.connect("mana_change", Callable(self, "_on_mana_change"))
	stats.connect("points_change", Callable(self, "_on_points_change"))
	
	%GameVersion.text = "SUNDAY IN HELL - %s" % [ProjectSettings.get_setting("application/config/version")]
	%CoreLevel.text = "Core " + str(stats.tank.core_tier)
	%TankName.text = stats.tank.tank_name
	%Username.text = stats.tank.username

func _process(delta):
	smooth_health += ((health_percent - smooth_health) / 10) * delta * 70
	%HealthBarOffset.value = smooth_health

	@warning_ignore("integer_division")
	mana_percent = stats.mana * 100 / stats.max_mana
	%ManaBar.value = mana_percent
	smooth_mana += ((mana_percent - smooth_mana) / 10) * delta * 70
	%ManaBarOffset.value = smooth_mana
	
	var points_left = stats.max_core_points - stats.points
	smooth_points_left += (points_left - smooth_points_left) / (150 * delta)
	%PointsLeft.text = str(smooth_points_left) + " Points left"

func _on_health_change(value):
	health_percent = value * 100 / stats.max_health
	%HealthBar.value = health_percent
	
func _on_rust_change(value):
	rust_percent = value * 100 / stats.max_rust
	%RustBar.value = rust_percent
	
func _on_mana_change(value):
	rust_percent = value * 100 / stats.max_mana
	%ManaBar.value = rust_percent
	
func _on_points_change(value):	
	points_percent = value * 100 / stats.max_core_points
	%CoreBar.value = points_percent
	animation_player.play("on_point")
