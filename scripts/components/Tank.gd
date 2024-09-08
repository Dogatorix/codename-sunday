extends CharacterBody2D
class_name Tank

@export_group("General")
@export var tank_name := "Tank"
@export var username := "Slow Joe"
@export_range(1, 4) var core_tier := 1

@export var default_zoom := 0.9
@export var is_client: bool = false

@export_group("References")
@export var component_container: Node
@onready var component_list = component_container.get_children()
	
var components := {}
var camera: GameCamera

var time_start = 0
var time_now = 0

func _ready():	
	for component in component_list:
		components[component.component_name] = component
		
	if is_client:
		Global.clients.push_front(self)
		
	if Global.clients.size() > 1:
		push_error(str(self) + " Overwriting client. Proprety reset.")
		Global.clients.erase(self)
		is_client = false
			
	if is_client:
		var camera_instance = GameCamera.new()
		camera_instance.zoom = Vector2(default_zoom, default_zoom)
		add_child(camera_instance)
		camera = camera_instance
		 
func _physics_process(delta):
	for component in component_list:
		if component.has_method("on_process"):
			component.on_process(delta)

func _exit_tree():
	Global.clients.erase(self)
