extends Node2D

enum CONTAINER_TYPE {
	SQUARE,
	TRIANGLE,
	PENTAGON,
	OCTAGON
}

@export var container_type: CONTAINER_TYPE = CONTAINER_TYPE.SQUARE
@export var healthbar: TextureProgressBar
@export var placeholder_node: Sprite2D
	
var container_scene: PackedScene
var container_instance
var healthbar_opacity: float = 1

@export var experience_orb_scene: PackedScene
var experience_instance: Node2D

# stuff set by the dispenser
var dispenser_owner: Node2D
var container_velocity_init: Vector2

func _ready():
	healthbar.visible = false	
	
	match container_type:
		CONTAINER_TYPE.SQUARE:
			container_scene = Global.PRELOADS["energy-square"]
		CONTAINER_TYPE.TRIANGLE:
			container_scene = Global.PRELOADS["energy-triangle"]
		CONTAINER_TYPE.PENTAGON:
			container_scene = Global.PRELOADS["energy-pentagon"]
		CONTAINER_TYPE.OCTAGON:
			container_scene = Global.PRELOADS["energy-octagon"]
			
	if container_scene:
		container_instance = container_scene.instantiate()
		container_instance.linear_velocity = container_velocity_init
		add_child(container_instance)
		
		container_instance.connect("health_change", _on_container_health_change)
		container_instance.connect("death", _on_death)
	else:
		print("Failed to preload container scene")

func _process(_delta):
	if container_instance:
		healthbar.position = container_instance.position + Vector2(-50, -60)
		healthbar.modulate = Color(1, 1, 1, min(1, healthbar_opacity))
		healthbar_opacity = max(0, healthbar_opacity - 0.02)
		
func _on_container_health_change(health):
	healthbar.visible = true	
	
	var tint_color = get_tint_color(healthbar.value)
	healthbar.tint_progress = tint_color
	
	healthbar_opacity += 1.5
	healthbar.value = container_instance.health * 100 / container_instance.max_health

func _on_death(energy, color):
	experience_instance = experience_orb_scene.instantiate()
	healthbar.visible = false
	$DeathTimer.start()
	
	experience_instance.color = color
	experience_instance.value = energy
	
	if dispenser_owner:
		dispenser_owner.payload_power += 1
	
	call_deferred("add_experience")
	

func add_experience():
	add_sibling(experience_instance)
	experience_instance.global_position = container_instance.global_position
	
func get_tint_color(value):
	var green_color = Color(0, 1, 0)
	var red_color = Color(1, 0, 0)
	
	var normalized_value = value / 100
	var tint_color = red_color.lerp(green_color, normalized_value)

	return tint_color
func _on_death_timer_timeout():
	queue_free()
