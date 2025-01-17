extends TankAIComponent
class_name Pathfind

@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var pathfind_process: Timer = %PathfindProcess

var target: Node2D

var movement: MovementBasic
var direction_smooth: Vector2

var pathfind_enabled := false

func pathfind_to_target():
	pathfind_process.start()
	pathfind_process.autostart = true

#func _process(delta):	
	#var direction = tank.to_local(navigation_agent.get_next_path_position()).normalized()
	#movement = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	#movement.input_vector = direction

	#if tank.global_position.distance_to(target.global_position) < 400:
		#target = get_tree().get_nodes_in_group("ai_node").pick_random()
#
#func _on_timer_timeout():

func _on_timer_timeout():
	navigation_agent.target_position = target.global_position
