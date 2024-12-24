extends Node2D

var chosen_node: Node2D = null
var is_being_dragged := false
var drag_offset := Vector2.ZERO

@onready var shoot_component = Global.Game.client.behaviour("shoot")

func _process(_delta):
	global_position = get_global_mouse_position()
	
	if chosen_node:
		chosen_node.global_position = global_position + drag_offset
	
	if Input.is_action_pressed("move-mode-drag") and not is_being_dragged:
		var node_list: Array = []
		
		for node in $Area2D.get_overlapping_areas():
			if not node.has_meta("can_be_dragged"):
				continue	
			node_list.push_front(node)
		for node in $Area2D.get_overlapping_bodies():
			if not node.has_meta("can_be_dragged"):
				continue	
			node_list.push_front(node)
		
		if node_list.size() < 1:
			return 
		
		chosen_node = node_list[0]
		for node: Node2D in node_list:
			if node.global_position.distance_to(global_position) < chosen_node.global_position.distance_to(global_position):
				chosen_node = node
		
		drag_offset = chosen_node.global_position - global_position
		is_being_dragged = true
		
		if shoot_component:
			shoot_component.prevent_shoot = true

		
	if Input.is_action_just_released("move-mode-drag"):
		is_being_dragged = false
		chosen_node = null
		
		if shoot_component:
			shoot_component.prevent_shoot = false
