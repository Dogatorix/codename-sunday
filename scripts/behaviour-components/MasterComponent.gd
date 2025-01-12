extends TankBehaviourComponent
class_name MasterComponent

@export var upgrades: Array[Enums.TANKS]
@export var tank_animations: AnimationPlayer
@export var colored_nodes: Array[Sprite2D]

var stats: StatsBasic
 	
func _setup_finished():
	tank.connect("on_upgrade_tank", _on_upgrade_tank)
	
	for node in colored_nodes:
		node.modulate = tank.tank_color
	
	await tank.stats_setup_finished
	stats = tank.behaviour(Enums.COMPONENTS.STATS)
	
	if not Global.Game.player_interface:
		Global.Game.add_player_interface()
	
	stats.connect("max_points", _on_max_points)
	
	
func _on_max_points():
	var shoot_component = tank.behaviour(Enums.COMPONENTS.SHOOT)
	shoot_component.disable_shoot()
		
	if tank.is_client:
		Global.Game.add_upgrade_menu(upgrades, Enums.TANK_TIERS.STARTER)
		%UpgradeShake.start()
		%UpgradeSound.start()

func _on_upgrade_tank(tank_id: Enums.TANKS):
	tank_animations.play("retract")
	%TransitionSound.start()
	await tank_animations.animation_finished
	tank.switch_tank_scene(tank_id)
