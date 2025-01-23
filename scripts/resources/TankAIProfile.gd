extends Resource
class_name TankAIProfile

# Attack

@export_group("Attack")
@export var attack_closeup_range: int = 300
@export var attack_orbit_deviation_angle: float = 1.5
@export var attack_memory: float = 8
@export var attack_min_health_allowed: int = 20
@export var attack_can_give_up: bool = false
@export var attack_combat_time_max: int = 40
@export var attack_min_health_to_give_up: int = 75
@export var attack_dash_chance: int = 30
