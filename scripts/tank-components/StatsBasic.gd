extends TankComponent
class_name StatsBasic

const component_name = "stats"

const CORE_REQUIREMENT = {
	1: 1,
	2: 500,
	3: 2000,
	4: 8000,
	5: 25000,
}

@export_group("General")
@export var max_health = 100
@export var max_rust = 100
@export var max_mana = 100
@export var mana_regeneration_rate := 20.0

var max_core_points := 1000

signal health_change(value)
signal rust_change(value)
signal mana_change(value)
signal points_change(value) 

@onready var health = max_health
@onready var mana = max_mana
var rust = 0
var points = 0

func _ready():
	if not tank:
		push_error(str(self) + " Tank reference missing. Really? Are you for real?")
		queue_free()
	pass

func set_health(value):
	health = value
	health_change.emit(value)
	
func set_rust(value):
	rust = value
	rust_change.emit(value)
	
func set_mana(value):
	mana = value
	mana_change.emit(value)
	
func set_points(value):
	points = value
	points_change.emit(value)	

func _process(delta):
	mana = min(100, mana + mana_regeneration_rate * delta)
