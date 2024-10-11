extends TankComponent
class_name DeathBasic

const component_name = "death"

@export var stats: StatsBasic
@export var spectator_scene: PackedScene
@export var death_scene: PackedScene

func _ready():
	safety_check([stats, spectator_scene])
	stats.connect("health_change", _on_health_change)
		
func _on_health_change(health):
	if health > 0:
		return
		
	var death_instance = death_scene.instantiate()
	death_instance.global_position = tank.global_position
	tank.add_sibling(death_instance)
	tank.queue_free()
	
	if tank.is_client: 
		var spectator_instance = spectator_scene.instantiate()
		spectator_instance.is_client = tank.is_client
		spectator_instance.camera_zoom = tank.default_zoom
		spectator_instance.global_position = tank.global_position
		tank.add_sibling(spectator_instance)
