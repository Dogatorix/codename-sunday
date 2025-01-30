extends TankAIComponent
class_name Shape

var master: MasterComponentAI

var target_shape: RigidBody2D
var closeup_range: int

func _setup_finished():
	master = tank.ai(Enums.AI_COMPONENTS.MASTER)
	master.state_changed.connect(state_update)
	var ai_profile: TankAIProfile = master.ai_profile
	
	closeup_range = int(ai_profile.shape_closeup_range)
	
func state_update(new_state):
	if not new_state == component_type:
		return

func update_nearest_shape():
	if master.nearest_shape == null:
		master.switch_state(Enums.AI_COMPONENTS.ROAMING)
		return
		
	target_shape = master.nearest_shape
	master.pathfind_to(target_shape.global_position)

func on_shape_death(_xp_instance):
	target_shape.disconnect("death", on_shape_death)
	

func _process(_delta):
	if not master.state == component_type:
		return
	
	if master.nearest_tank != null:
		master.switch_state(Enums.AI_COMPONENTS.ATTACK)
	
	if target_shape == null:
		update_nearest_shape()
	else:
		master.look_at_position(target_shape.global_position)
	
	var shape_in_vision = not master.ray_cast_collider is TileMapLayer
	
	if target_shape == null:
		master.switch_state(Enums.AI_COMPONENTS.ROAMING)
		return
	
	var shape_distance = tank.global_position.distance_to(target_shape.global_position)
	
	if shape_in_vision and shape_distance < 250:
		var shoot = tank.behaviour(Enums.COMPONENTS.SHOOT)
		shoot.ai_shoot()
		master.pathfind_disabled = true
	else:
		update_nearest_shape()

func get_next_orbit_position(position: Vector2):
	var alpha = randf_range(-2, 2)
	var alpha_angle = position.angle_to_point(tank.global_position) + alpha
	var distance = Vector2.from_angle(alpha_angle) * randi_range(closeup_range, closeup_range + 75)
	
	return target_shape.global_position + distance
