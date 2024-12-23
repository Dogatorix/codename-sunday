extends CharacterBody2D
class_name Tank

enum TIERS {
	BASIC = 1,
	STARTER = 2,
	INDUSTRIAL = 3,
	PIONEER = 4,
}

@export_group("General")
@export var tank_name := "Tank"
@export var tank_color := Color(1,1,1)
@export var username := "Slow Joe"
@export var core_tier: TIERS = TIERS.BASIC
 
@export var default_zoom := 0.9
@export var is_client: bool = false

@export_group("References")
@export var component_container: ComponentList
@export var ai_component_container: AIComponentList
	
@export var core_sprite: Sprite2D
@export var sprite_node: Node2D
@onready var component_list = component_container.get_children()
	
var components := {}
var camera: GameCamera

var upgraded := false

func _ready():
	set_meta("can_be_dragged", true)
	
	for component in component_list:
		components[component.component_name] = component
		
	if is_client: 
		Global.clients.push_front(self)
		
	if Global.clients.size() > 1:
		push_error(str(self) + " Overwriting client. Proprety reset.")
		Global.clients.erase(self)
		is_client = false
		
	if not upgraded:
		check_data()
		
	if is_client and ai_component_container:
		ai_component_container.queue_free()
		 
func _physics_process(delta):
	for component in component_list:
		if component.has_method("on_process"):
			component.on_process(delta)
		
func upgrade_tank(tank_scene: PackedScene):
	var tank_instance: Tank = tank_scene.instantiate()
	Global.clients.erase(self)
	is_client = false
	
	tank_instance.is_client = true
	tank_instance.upgraded = true
	add_sibling(tank_instance)
	
	if sprite_node and tank_instance.sprite_node:
		tank_instance.sprite_node.rotation_degrees = sprite_node.rotation_degrees
	
	tank_instance.tank_color = tank_color
	tank_instance.username = username
	
	tank_instance.global_position = global_position
	tank_instance.check_data()
	queue_free()

func check_data():
	if is_client:
		var camera_instance = GameCamera.new()
		camera_instance.zoom = Vector2(default_zoom, default_zoom)
		add_child(camera_instance)
		camera = camera_instance
	if core_sprite:
		tank_color.a = 1
		core_sprite.modulate = tank_color

func update_color(color: Color):
	tank_color = color
	core_sprite.modulate = tank_color
	
	# FIXME - MAKE TANK COLORS UPDATE

func component(name: String):
	return components[name]

func _exit_tree():
	Global.clients.erase(self)
