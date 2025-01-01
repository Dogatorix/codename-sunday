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

var Game: GameGlobal
var username := "Slow Joe"
var device: DEVICE

var is_mobile: bool:
	get:
		return device == DEVICE.MOBILE
		
var is_desktop: bool:
	get:
		return device == DEVICE.DESKTOP

func on_fade_in_finished():
	fade_in_complete.emit()

func fade_in():
	%FadeAnimations.play("fade_in")
	
func fade_out():
	%FadeAnimations.play("fade_out")

func _process(_delta):
	if Input.is_action_just_pressed("restart-debug") or Input.is_action_just_pressed("respawn"):
		restarted.emit()
		get_tree().reload_current_scene()
		
	%FPS.text = "FPS:" + str(Engine.get_frames_per_second())
	var memory_usage = OS.get_static_memory_usage() / 1000000.0
	%Memory.text = "Memory: " + str(int(memory_usage)) + "MB"
		
func _ready():
	var os_name = OS.get_name()
	if os_name == "Windows" or os_name == "macOS" or os_name == "Linux":
		device = DEVICE.DESKTOP
	else:
		device = DEVICE.MOBILE 
	
	create_game(Enums.GAMEMODES.SANDBOX)
	
	this_is_necessary_pinky_promise_do_not_remove()

func this_is_necessary_pinky_promise_do_not_remove():
	if not FileAccess.file_exists("res://coconut.png"):
		get_parent().fuck_you()

func tween(target: Object, property, final_value, duration: float, transition: Tween.TransitionType = Tween.TransitionType.TRANS_EXPO, easing: Tween.EaseType = Tween.EaseType.EASE_OUT):
	var tween: Tween = create_tween()
	tween.set_ease(easing)
	tween.set_trans(transition)
	tween.tween_property(target, property, final_value, duration)
	
	return tween
	
@export var game_scene: PackedScene
func create_game(gamemode: Enums.GAMEMODES):
	Game = game_scene.instantiate()
	Game.gamemode = gamemode
	add_child(Game)
