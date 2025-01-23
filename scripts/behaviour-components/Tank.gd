extends CharacterBody2D
class_name Tank

signal on_upgrade_tank(tank: Enums.TANKS)
signal tank_switched()

signal stats_setup_finished()
signal movement_finished()

@export var tank_name := "Tank"
@export var tank_color := Color(1,1,1)
@export var username := "Slow Joe"
@export var tank_id: Enums.TANKS

@onready var player_bars = $PlayerBars

@export var default_zoom := 0.9
@export var is_client: bool
@export var is_ai: bool

### THIS IS TEMPORARY!!!
@export var ai_content_scene: PackedScene


var behaviour_components := {}
var ai_components := {}

var camera: GameCamera

var current_content_instance: Node2D

var is_spawning := true


var Game:
	get():
		return Global.Game

func _ready():
	$Icon.queue_free()

	if is_client: 
		Game.clients.push_front(self)
		
	if Game.clients.size() > 1:
		push_error(str(self) + " Overwriting client. Proprety reset.")
		Game.clients.erase(self)
		is_client = false
		
	if is_client:
		setup_client()
	
	if is_ai:
		setup_ai()
	
	var tank_content_scene: PackedScene = Global.Game.tank_scenes[tank_id].scene
	current_content_instance = tank_content_scene.instantiate()
	add_child(current_content_instance)

func setup_client():
	if Global.is_mobile:
		Global.Game.Mobile.enable_tank_controls()
		
	var camera_instance = GameCamera.new()
	camera_instance.zoom = Vector2(default_zoom, default_zoom)
	add_child(camera_instance)
	camera = camera_instance
	Game.Overlay.hide_bars()
	Global.fade_out()
	is_ai = false

func setup_ai():
	var ai_instance = ai_content_scene.instantiate()
	add_child(ai_instance)
	

func switch_tank_scene(tank: Enums.TANKS):
	is_spawning = false
	var tank_content_scene: PackedScene = Global.Game.tank_scenes[tank].scene
	var new_content_instance = tank_content_scene.instantiate()
	add_child(new_content_instance)
	current_content_instance.queue_free()
	current_content_instance = new_content_instance
	tank_id = tank
	
	tank_switched.emit()
	
func _process(_delta):
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * 100)
	
func upgrade_tank(tank: Enums.TANKS):
	on_upgrade_tank.emit(tank)
	
func behaviour(component_name: Enums.COMPONENTS):
	if not behaviour_components.has(component_name):
		return null
		
	return behaviour_components[component_name]
	
func ai(component_name: Enums.AI_COMPONENTS):
	return ai_components[component_name]

func _exit_tree():
	Game.clients.erase(self)
