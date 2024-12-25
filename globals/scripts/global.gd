extends Node

signal restarted()

@export var game_scene: PackedScene

var Game: Node

func _process(_delta):
	if Input.is_action_just_pressed("restart"):
		restarted.emit()
		get_tree().reload_current_scene()

func _ready():
	this_is_necessary_pinky_promise_do_not_remove()

func this_is_necessary_pinky_promise_do_not_remove():
	if not FileAccess.file_exists("res://coconut.png"):
		get_parent().fuck_you()
