extends Node
class_name BehaviourComponentList

func _ready():
	if not get_parent() is ComponentList:
		push_error("Invalid BehaviourComponentList placement!")
		queue_free()
		return	
