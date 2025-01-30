extends TankAIComponent
class_name Attack

@onready var navigation_agent = %NavigationAgent2D

var master: MasterComponentAI
var flee: Flee
var stats: StatsBasic

var closeup_range: int
var orbit_deviation_angle: float

var tank_memory_max: float
var tank_memory: float

var tank_target: Tank

var min_health_allowed: int

var can_give_up: bool

var combat_time_max: int
var min_health_to_give_up: int
var combat_time: float
var dash_chance: int

var shoot_through_walls: bool

func _setup_finished():
	master = tank.ai(Enums.AI_COMPONENTS.MASTER)
	var ai_profile: TankAIProfile = master.ai_profile
	
	closeup_range = ai_profile.attack_closeup_range
	orbit_deviation_angle = ai_profile.attack_orbit_deviation_angle
	tank_memory_max = ai_profile.attack_memory
	min_health_allowed = ai_profile.attack_min_health_allowed
	can_give_up = ai_profile.attack_can_give_up
	combat_time_max = ai_profile.attack_combat_time_max
	min_health_to_give_up = ai_profile.attack_min_health_to_give_up
	dash_chance = ai_profile.attack_dash_chance
	shoot_through_walls = ai_profile.shoot_through_walls
	
	tank_memory = tank_memory_max
	
	if not tank.behaviour(Enums.COMPONENTS.STATS):
		await tank.stats_setup_finished
	
	stats = tank.behaviour(Enums.COMPONENTS.STATS)
	master.state_changed.connect(state_update)
	
func state_update(new_state: Enums.AI_COMPONENTS):
	if not new_state == component_type:
		return
	
	if master.nearest_tank == null:
		return
		
	master.target_position = get_next_orbit_position(master.nearest_tank.global_position)
	combat_time = 0
	
func _process(delta):
	if not master.state == component_type:
		return
		
	var stats = tank.behaviour(Enums.COMPONENTS.STATS)
	
	if stats == null:
		await tank.stats_setup_finished
		stats = tank_target.behaviour(Enums.COMPONENTS.STATS)
		
	if master.players_in_vision.size() < 1 and not tank_target:
		master.switch_state(Enums.AI_COMPONENTS.ROAMING)
		
	if master.players_in_vision.size() < 1 and tank_target:
		tank_memory = max(0, tank_memory - delta)
		if tank_memory <= 0:
			master.switch_state(Enums.AI_COMPONENTS.ROAMING)
		
	if master.nearest_tank != null:
		tank_target = master.nearest_tank
		tank_memory = tank_memory_max
		
	if tank_target:
		combat_time += delta
		handle_orbit()
		master.pathfind_disabled = false
	
	var health_condition: bool = false
	
	if tank_target != null:
		health_condition = tank_target.behaviour(Enums.COMPONENTS.STATS).health > min_health_to_give_up
		
	var give_up_condition = can_give_up and combat_time > combat_time_max and health_condition
	
	if give_up_condition or stats.health < min_health_allowed:
		tank.ai(Enums.AI_COMPONENTS.FLEE).flee_target = tank_target
		master.switch_state(Enums.AI_COMPONENTS.FLEE)
	
	#%Label.text = str(int(combat_time))	
	

func handle_orbit():
	if tank == null or master.nearest_tank == null:
		return
	
	if tank.global_position.distance_to(master.target_position) < 100 \
	or master.nearest_tank.global_position.distance_to(master.target_position) < closeup_range - 200 \
	or not navigation_agent.is_target_reachable():
		master.target_position = get_next_orbit_position(master.nearest_tank.global_position)
	
	if not master.ray_cast_collider is TileMapLayer or shoot_through_walls: 
		var shoot = tank.behaviour(Enums.COMPONENTS.SHOOT)
		shoot.ai_shoot()
	
	master.look_at_position(master.nearest_tank.global_position)

func get_next_orbit_position(position: Vector2):
	var alpha = randf_range(-orbit_deviation_angle, orbit_deviation_angle)
	var alpha_angle = position.angle_to_point(tank.global_position) + alpha
	var distance = Vector2.from_angle(alpha_angle) * randi_range(closeup_range, closeup_range + 250)
	
	return master.nearest_tank.global_position + distance

func _on_dash_delay_timeout():
	if not component_type == master.state or master.ray_cast_collider is TileMapLayer:
		return
	
	if Global.random_chance(dash_chance): 
		var tank_dash: DashBasic = tank.behaviour(Enums.COMPONENTS.DASH)
		tank_dash.dash()
