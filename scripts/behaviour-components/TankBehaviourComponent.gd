extends Node
class_name TankBehaviourComponent

signal setup_finished()

@export var component_type: Enums.COMPONENTS

var tank: Tank
var is_finished := false

func safety_check(nodes: Array):
	for node in nodes:
		if not node:
			push_error(str(self) + " Component refence(s) missing!")
			queue_free()
			break

func _ready():
	set_process(false)
	
	tank = get_parent().get_parent().get_parent()
	tank.behaviour_components[component_type] = self
	
	setup_finished.emit()
	
	if has_method("_setup_finished"):
		call("_setup_finished")
		
	is_finished = true
	set_process(true)
