extends Node

signal restarted()
signal fade_in_complete()

enum DEVICE {
	MOBILE,
	DESKTOP
}

const TANK_NAMES := {
	Enums.TANKS.BASIC: "Basic",
	Enums.TANKS.ASSAULT: "Assault",
	Enums.TANKS.DESTROY: "Destroy",
	Enums.TANKS.CRUSH: "Crush"
}

var is_logged_in: bool = false
var username := "Slow Joe"
var device: DEVICE

var is_mobile: bool:
	get:
		return device == DEVICE.MOBILE
		#return true
		
var is_desktop: bool:
	get:
		return device == DEVICE.DESKTOP
		#return false

func on_fade_in_finished():
	fade_in_complete.emit()

func fade_in():
	%FadeAnimations.play("fade_in")
	
func fade_out():
	%FadeAnimations.play("fade_out")

func _process(_delta):
	if Input.is_action_just_pressed("restart-debug") or Input.is_action_just_pressed("respawn"):
		restarted.emit()
		
	%FPS.text = "FPS:" + str(Engine.get_frames_per_second())
	var memory_usage = OS.get_static_memory_usage() / 1000000.0
	%Memory.text = "Memory: " + str(int(memory_usage)) + "MB"
		
func _ready():
	var os_name = OS.get_name()
	if os_name == "Windows" or os_name == "macOS" or os_name == "Linux" or os_name == "Web":
		device = DEVICE.DESKTOP
	else:
		device = DEVICE.MOBILE 
		
	this_is_necessary_pinky_promise_do_not_remove()

func this_is_necessary_pinky_promise_do_not_remove():
	if not FileAccess.file_exists("res://coconut.png"):
		get_parent().fuck_you()

func tween(target: Object, property, final_value, duration: float, transition: Tween.TransitionType = Tween.TransitionType.TRANS_EXPO, easing: Tween.EaseType = Tween.EaseType.EASE_OUT):
	var new_tween: Tween = create_tween()
	new_tween.set_ease(easing)
	new_tween.set_trans(transition)
	new_tween.tween_property(target, property, final_value, duration)
	
	return new_tween
	
@export var game_scene: PackedScene
var Game: GameGlobal
func create_game(gamemode: Enums.GAMEMODES):
	Game = game_scene.instantiate()
	Game.gamemode = gamemode
	add_child(Game)
	return Game

func find_nearest_node(origin: Vector2, nodes: Array):
	if nodes.size() <= 0:
		return null
	
	var contender = nodes[0]
	
	for node in nodes:
		if origin.distance_to(node.global_position) < origin.distance_to(contender.global_position):
			contender = node 
	return contender

func switch_current_scene(scene_path: String):
	get_tree().current_scene.queue_free()
	get_tree().current_scene = null
	
	var new_scene: PackedScene = load(scene_path)

	var instances_scene := new_scene.instantiate()
	get_tree().root.add_child(instances_scene)
	get_tree().current_scene = instances_scene

func random_chance(chance: float):
	return randi_range(0,100) <= chance
