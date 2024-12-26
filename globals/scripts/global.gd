extends Node

signal restarted()

@export var game_scene: PackedScene

enum DEVICE {
	MOBILE,
	DESKTOP
}

var Game: Node
var username := "Slow Joe"
var device: DEVICE

var is_mobile: bool:
	get:
		return device == DEVICE.MOBILE
		
var is_desktop: bool:
	get:
		return device == DEVICE.DESKTOP

func _process(_delta):
	if Input.is_action_just_pressed("restart-debug") or Input.is_action_just_pressed("respawn"):
		restarted.emit()
		get_tree().reload_current_scene()
		
func _ready():
	var os_name = OS.get_name()
	if os_name == "Windows" or os_name == "macOS" or os_name == "Linux":
		device = DEVICE.DESKTOP
	else:
		device = DEVICE.MOBILE 
	
	Game = game_scene.instantiate()
	add_child(Game)
	
	this_is_necessary_pinky_promise_do_not_remove()

func this_is_necessary_pinky_promise_do_not_remove():
	if not FileAccess.file_exists("res://coconut.png"):
		get_parent().fuck_you()
