extends Node
class_name TankBehaviourComponent

@export var tank: Tank

func safety_check(nodes: Array):
	for node in nodes:
		if not node:
			push_error(str(self) + " Component refence(s) missing!")
			queue_free()
			break

func _ready():
	safety_check([tank])
	
	if not get_parent() is BehaviourComponentList:
		push_error(str(self) + " Invalid component placement")
		queue_free()
