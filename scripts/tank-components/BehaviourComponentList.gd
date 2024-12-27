extends Node
class_name BehaviourComponentList

@export var data_node: Node
@onready var tank: Tank = data_node.tank

func _ready():
	if not get_parent() is ComponentList:
		push_error("Invalid BehaviourComponentList placement!")
		queue_free()
		return
		
	for component in get_children():
		tank.components[component.component_name] = component
		
		if component.has_method("on_ready"):
			component.on_ready()

func _process(delta):
	for component in get_children():
		if component.has_method("on_process"):
			component.on_process(delta)
