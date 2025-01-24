extends TankAIComponent
class_name MasterComponentAI

signal state_changed(state: Enums.AI_COMPONENTS)
signal tank_entered(tank: Tank)
signal tank_exited(tank: Tank)

@export var ai_profile: TankAIProfile
@onready var ray_cast: RayCast2D = %RayCast

var ray_cast_collider:
	get:
		return ray_cast.get_collider()
		
var state: Enums.AI_COMPONENTS = Enums.AI_COMPONENTS.ROAMING

var players_in_vision: Array[Tank] = []
var nearest_tank: Tank

var look_target_position: Vector2
var look_target_smooth: Vector2

var pathfind_disabled: bool = true

@onready var navigation_agent = %NavigationAgent2D

var target_position: Vector2

var tank_path_direction: Vector2
var tank_target_rotation: float

var movement: MovementBasic

func _setup_finished():
	%PathfindProcess.connect("timeout", _on_pathfind_process)
	
func _on_pathfind_process():
	navigation_agent.target_position = target_position

func pathfind_to(position: Vector2):
	pathfind_disabled = false
	target_position = position

func get_path_direction():
	return tank.to_local(navigation_agent.get_next_path_position()).normalized()

func _process(_delta):
	movement = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	
	if not pathfind_disabled:
		tank_path_direction = get_path_direction()
		movement.input_vector = tank_path_direction
	else:
		movement.input_vector = Vector2.ZERO
		
	look_target_smooth += (look_target_position - look_target_smooth) / 6
	tank_target_rotation = rad_to_deg((tank.global_position - look_target_smooth).angle()) - 90
	movement.tank_sprite.rotation_degrees = tank_target_rotation
	ray_cast.rotation_degrees = movement.tank_sprite.rotation_degrees 
	
func switch_state(new_state: Enums.AI_COMPONENTS):
	state = new_state
	state_changed.emit(new_state)
	
func _view_entered(body):
	if not body == tank and body is CharacterBody2D:
		if body.is_client and Settings.ai_ignore_client:
			return
		
		players_in_vision.push_front(body)
		update_nearest_tank()
		tank_entered.emit(body)
		if not body.is_connected("tree_exiting", erase_player_from_vision):
			body.connect("tree_exiting", erase_player_from_vision.bind(body))

func erase_player_from_vision(body: CharacterBody2D):
	update_nearest_tank()
	players_in_vision.erase(body)

func _view_exited(body):
	if not body == tank and body is CharacterBody2D:
		update_nearest_tank()
		players_in_vision.erase(body)
		tank_exited.emit(body)

func update_nearest_tank():
	nearest_tank = Global.find_nearest_node(tank.global_position, players_in_vision)
	
func look_at_position(position: Vector2):
	look_target_position = position
