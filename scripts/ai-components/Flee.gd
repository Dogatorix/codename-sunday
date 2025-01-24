extends TankAIComponent
class_name Flee

var flee_target: Tank
var master: MasterComponentAI

var flee_timer_max: float
var dash_chance: int
var flee_timer := 0.0

var shoot_through_walls: bool

func _setup_finished():
	master = tank.ai(Enums.AI_COMPONENTS.MASTER)
	master.state_changed.connect(state_update)
	
	var ai_profile: TankAIProfile = master.ai_profile
	flee_timer_max = ai_profile.flee_timer_max
	dash_chance = ai_profile.flee_dash_chance
	shoot_through_walls = ai_profile.shoot_through_walls
	
func state_update(new_state):
	if not new_state == component_type:
		return
		
	flee_timer = 0
	set_target_point(flee_target.global_position)

func _process(delta):
	if not master.state == component_type:
		return
		
	flee_timer += delta
	
	if flee_timer > flee_timer_max:
		master.switch_state(Enums.AI_COMPONENTS.ROAMING)
	
	if flee_target != null:
		master.look_at_position(flee_target.global_position)
	else:
		master.switch_state(Enums.AI_COMPONENTS.ROAMING)
	
	var shoot = tank.behaviour(Enums.COMPONENTS.SHOOT)
	shoot.ai_shoot()

func set_target_point(position: Vector2):
	var alpha_angle = position.angle_to_point(tank.global_position)
	var target_node = fartherst_node(tank.global_position, Global.Game.path_points)
	master.pathfind_to(target_node)

func fartherst_node(origin: Vector2, points: Array[Vector2]):
	if points.size() <= 0:
		return null
	
	var contender = points[0]
	
	for point in points:
		if origin.distance_to(point) > origin.distance_to(contender):
			contender = point 
	return contender

func _on_dash_delay_timeout():
	if not component_type == master.state:
		return
	
	if randi_range(0,100) <= dash_chance: 
		var tank_dash: DashBasic = tank.behaviour(Enums.COMPONENTS.DASH)
		tank_dash.dash()
