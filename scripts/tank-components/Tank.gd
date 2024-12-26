extends CharacterBody2D
class_name Tank

enum TANKS {
	BASIC,
	CRUSH,
	ASSAULT,
	DESTROY,
}

@export var tank_name := "Tank"
@export var tank_color := Color(1,1,1)
@export var username := "Slow Joe"
@export var tank_id: TANKS = TANKS.BASIC

@onready var player_bars = $PlayerBars

@export var default_zoom := 0.9
@export var is_client: bool = false

var components := {}
var ai_components := {}

var camera: GameCamera

var Game:
	get():
		return Global.Game

func _ready():
	if is_client: 
		Game.clients.push_front(self)
		
	if Game.clients.size() > 1:
		push_error(str(self) + " Overwriting client. Proprety reset.")
		Game.clients.erase(self)
		is_client = false
		
	if is_client and Global.is_mobile:
		Global.Game.Mobile.enable_tank_controls()
		
	if is_client:
		var camera_instance = GameCamera.new()
		camera_instance.zoom = Vector2(default_zoom, default_zoom)
		add_child(camera_instance)
		camera = camera_instance
	
	var tank_content_scene: PackedScene = Global.Game.tank_scenes[tank_id].scene
	var tank_content_instance = tank_content_scene.instantiate()
	add_child(tank_content_instance)
	
func upgrade_tank(tank: TANKS):
	return
	
func _physics_process(delta):
	if Input.is_action_just_pressed("debug"):
		behaviour("stats").damage_tank(100)
	
func behaviour(name: String):
	return components[name]
	
func ai(name: String):
	return ai_components[name]

func _exit_tree():
	Game.clients.erase(self)
