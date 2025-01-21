extends TankAIComponent
class_name Roaming

var master: MasterComponentAI
var chosen_point: Vector2

func _setup_finished():
	master = tank.ai(Enums.AI_COMPONENTS.MASTER)
	master.state_changed.connect(state_update)
	master.switch_state(Enums.AI_COMPONENTS.ROAMING)

func state_update(new_state):
	if not new_state == component_type:
		return
		
	chosen_point = Global.Game.path_points.pick_random()
	master.pathfind_to(chosen_point)

func _process(_delta):
	if not master.state == component_type:
		return 
	
	var look_direction = tank.global_position - (master.get_path_direction() * -200)
	master.look_at_position(look_direction)
	
	if tank.global_position.distance_to(chosen_point) < 200:
		chosen_point = Global.Game.path_points.pick_random()
		master.pathfind_to(chosen_point)
