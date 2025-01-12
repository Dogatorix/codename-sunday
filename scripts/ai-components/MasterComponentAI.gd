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

func _process(delta):
	look_target_smooth += (look_target_position - look_target_smooth) / 5
	var movement: MovementBasic = tank.behaviour(Enums.COMPONENTS.MOVEMENT)
	var target_rotation: float = rad_to_deg((tank.global_position - look_target_smooth).angle()) - 90
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
