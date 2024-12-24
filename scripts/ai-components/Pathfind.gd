extends TankAIComponent
class_name Pathfind

const component_name = "pathfind"

@export var navigation_agent: NavigationAgent2D
var target: Node2D

var movement: MovementBasic
var direction_smooth: Vector2

var disable := false

func _ready():
	target = get_tree().get_nodes_in_group("ai_node").pick_random()
	
func _process(delta):
	var tank: Tank = data_node.tank
	
	var direction = tank.to_local(navigation_agent.get_next_path_position()).normalized()
	movement = tank.behaviour("movement")
	movement.input_vector = direction
	
	direction_smooth += ((direction - direction_smooth) / 10) * delta * 90
	
	movement.rotate_tank(rad_to_deg(direction_smooth.angle()) + 90)
	
	if tank.global_position.distance_to(target.global_position) < 400:
		target = get_tree().get_nodes_in_group("ai_node").pick_random()

func _on_timer_timeout():
	navigation_agent.target_position = target.global_position
