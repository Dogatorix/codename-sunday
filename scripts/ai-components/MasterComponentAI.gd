extends TankAIComponent
class_name MasterComponentAI

var players_in_vision: Array[Tank] = []
var nearest_tank: Tank

var look_direction_delta := 0.0
var look_direction := 0.0
var look_direction_smooth := 0.0

var look_switch_chance := 30.0

var look_target_position: Vector2
var look_target_smooth: Vector2

@export var closeup_range: int

@onready var navigation_agent = %NavigationAgent2D

func _setup_finished():
	%PathfindProcess.connect("timeout", _on_pathfind_process)

func _on_pathfind_process():
	navigation_agent.target_position = Global.Game.client.global_position

func _process(delta):
	
	var target_tank = Global.Game.client
	
	var movement: MovementBasic = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	var target_rotation: float = rad_to_deg((tank.global_position - look_target_smooth).angle()) - 90
	
	var tank_direction = tank.to_local(navigation_agent.get_next_path_position()).normalized()
	
	#if tank.global_position.distance_to(target_tank.global_position) > closeup_range:
		#movement.input_vector = tank_direction
	#elif tank.global_position.distance_to(target_tank.global_position) < (closeup_range - 150):
		#movement.input_vector = -tank_direction
	#else:
		#movement.input_vector = Vector2.ZERO
	
	look_target_smooth += (look_target_position - look_target_smooth) / 5
	movement.tank_sprite.rotation_degrees = target_rotation
	look_at_position(Global.Game.client.global_position)
	
func _view_entered(body):
	if not body == tank and body is Tank:
		players_in_vision.push_front(body)

func _view_exited(body):
	if not body == tank and body is Tank:		
		players_in_vision.erase(body)

func update_nearest_tank():
	nearest_tank = Global.find_nearest_node(tank.global_position, players_in_vision)

func look_at_position(position: Vector2):
	look_target_position = position

func _draw():
	pass

#func _process(delta):	
	#var direction = tank.to_local(navigation_agent.get_next_path_position()).normalized()
	#movement = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	#movement.input_vector = direction
#
	#if tank.global_position.distance_to(target.global_position) < 400:
		#target = get_tree().get_nodes_in_group("ai_node").pick_random()

#func _on_timer_timeout():
#
#func _on_timer_timeout():
