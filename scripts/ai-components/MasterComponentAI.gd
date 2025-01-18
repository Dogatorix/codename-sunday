extends TankAIComponent
class_name MasterComponentAI

var players_in_vision: Array[Tank] = []
var nearest_tank: Tank

var look_target_position: Vector2
var look_target_smooth: Vector2

var pathfind_disabled: bool

@export var closeup_range: int
@export_range(0,2) var orbit_deviation_angle: float

@onready var navigation_agent = %NavigationAgent2D

var target_position: Vector2

var tank_path_direction: Vector2
var tank_target_rotation: float

var movement: MovementBasic

func _setup_finished():
	%PathfindProcess.connect("timeout", _on_pathfind_process)

func _on_pathfind_process():
	navigation_agent.target_position = target_position

func _process(delta):
	movement = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	
	if not pathfind_disabled:
		tank_path_direction = tank.to_local(navigation_agent.get_next_path_position()).normalized()
		movement.input_vector = tank_path_direction
	else:
		movement.input_vector = Vector2.ZERO
		
	tank_target_rotation = rad_to_deg((tank.global_position - look_target_smooth).angle()) - 90
	look_target_smooth += (look_target_position - look_target_smooth) / 5
	movement.tank_sprite.rotation_degrees = tank_target_rotation
	
	if nearest_tank != null:
		handle_orbit()
		pathfind_disabled = false
	else:
		pathfind_disabled = true
		look_at_position(tank.global_position + Vector2(0, -100))
	
func handle_orbit():
	if tank.global_position.distance_to(target_position) < 100 \
	or nearest_tank.global_position.distance_to(target_position) < closeup_range - 200 \
	or not navigation_agent.is_target_reachable():
		target_position = get_next_orbit_position(nearest_tank.global_position)
	
	var shoot = tank.behaviour(Enums.COMPONENTS.SHOOT)
	shoot.ai_shoot()
	
	look_at_position(nearest_tank.global_position)
	
func _view_entered(body):
	if not body == tank and body is CharacterBody2D:
		players_in_vision.push_front(body)
		update_nearest_tank()
		if not body.is_connected("tree_exiting", erase_player_from_vision):
			body.connect("tree_exiting", erase_player_from_vision.bind(body))

func erase_player_from_vision(body: CharacterBody2D):
	update_nearest_tank()
	players_in_vision.erase(body)

func _view_exited(body):
	if not body == tank and body is CharacterBody2D:		
		update_nearest_tank()
		players_in_vision.erase(body)

func update_nearest_tank():
	nearest_tank = Global.find_nearest_node(tank.global_position, players_in_vision)
	
	if nearest_tank:
		target_position = get_next_orbit_position(nearest_tank.global_position)
	
func look_at_position(position: Vector2):
	look_target_position = position

func get_next_orbit_position(position: Vector2):
	var alpha = randf_range(-orbit_deviation_angle, orbit_deviation_angle)
	var alpha_angle = position.angle_to_point(tank.global_position) + alpha
	var distance = Vector2.from_angle(alpha_angle) * randi_range(closeup_range, closeup_range + 200)
	
	return nearest_tank.global_position + distance
