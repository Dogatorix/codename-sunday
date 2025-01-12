extends Node
class_name TankAIComponent

signal setup_finished()

@export var component_type: Enums.AI_COMPONENTS

var tank: Tank
var is_finished := false

func _ready():
	set_process(false)
	
	tank = get_parent().get_parent().get_parent()
	tank.ai_components[component_type] = self
	
	setup_finished.emit()
	
	if has_method("_setup_finished"):
		call("_setup_finished")
		
	is_finished = true
	set_process(true)
