extends Node

#@export var Game: Node
@export var game_scene: PackedScene

var Game: Node

func _ready():
	Game = game_scene.instantiate()
	add_child.call_deferred(Game)
	
	if not FileAccess.file_exists("res://coconut.png"):
		get_parent().fuck_you()	
