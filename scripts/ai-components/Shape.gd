extends TankAIComponent
class_name Shape

var master: MasterComponentAI

var target_shape: RigidBody2D
var closeup_range: int

func _setup_finished():
	master = tank.ai(Enums.AI_COMPONENTS.MASTER)
	master.state_changed.connect(state_update)
	var ai_profile: TankAIProfile = master.ai_profile
	
	closeup_range = ai_profile.shape_closeup_range
	
func state_update(new_state):
	if not new_state == component_type:
		return
	
	target_shape = master.nearest_shape
	master.pathfind_to(target_shape.global_position)

func _process(delta):
	if not master.state == component_type:
		return

	master.look_at_position(target_shape.global_position)

	 
	
	#%Label.text = str(tank.global_position.distance_to(target_shape.global_position))

func get_next_orbit_position(position: Vector2):
	var alpha = randf_range(-2, 2)
	var alpha_angle = position.angle_to_point(tank.global_position) + alpha
	var distance = Vector2.from_angle(alpha_angle) * randi_range(closeup_range, closeup_range + 75)
	
	return target_shape.global_position + distance
