extends TankAIComponent
class_name Roaming

var master: MasterComponentAI
var chosen_point: Vector2

var min_health_allowed: int

func _setup_finished():
	master = tank.ai(Enums.AI_COMPONENTS.MASTER)
	var ai_profile: TankAIProfile = master.ai_profile
	
	min_health_allowed = ai_profile.attack_min_health_allowed
	
	master.state_changed.connect(state_update)
	master.tank_entered.connect(_on_tank_entered)
	master.shape_entered.connect(_on_shape_entered)
	master.switch_state(Enums.AI_COMPONENTS.ROAMING)
	%Delay.wait_time = randf_range(0.2, 0.5)

func _on_shape_entered(_target_shape):
	if not master.state == component_type:
		return
		
	#master.switch_state(Enums.AI_COMPONENTS.SHAPE)

func _on_tank_entered(target_tank: Tank):
	if not master.state == component_type:
		return
	
	if tank.behaviour(Enums.COMPONENTS.STATS).health > min_health_allowed:
		%Delay.start()
		await %Delay.timeout
		master.switch_state(Enums.AI_COMPONENTS.ATTACK)	
	else:
		tank.ai(Enums.AI_COMPONENTS.FLEE).flee_target = target_tank
		master.switch_state(Enums.AI_COMPONENTS.FLEE)

func state_update(new_state):
	if not new_state == component_type:
		return
	
	if master.nearest_tank:
		_on_tank_entered(master.nearest_tank)
	
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
