extends Resource
class_name TankAIProfile

@export_group("General")
@export var shoot_through_walls: bool = false
@export var activate_train_chance: bool = 25

@export_group("Attack")
@export var attack_closeup_range: int = 300
@export var attack_orbit_deviation_angle: float = 1.5
@export var attack_memory: float = 8
@export var attack_min_health_allowed: int = 20
@export var attack_can_give_up: bool = false
@export var attack_combat_time_max: int = 40
@export var attack_min_health_to_give_up: int = 75
@export var attack_dash_chance: int = 20

@export_group("Flee")
@export var flee_timer_max: float = 5.0
@export var flee_dash_chance: int = 35

@export_group("Shape")
@export var shape_closeup_range: float = 300
