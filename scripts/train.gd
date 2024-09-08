extends Node

@onready var gate_start: Node2D = get_node_or_null("TrainGateStart")
@onready var gate_end: Node2D = get_node_or_null("TrainGateEnd")
@onready var activator: Area2D = get_node_or_null("TrainActivator")

@export var train_scene: PackedScene
var train_instance: StaticBody2D

var is_activator_on := false

func _ready():
	if !gate_start or !gate_end or !activator:
		push_error(str(self) + " Missing component(s)")
		queue_free()
		return
	
	train_instance = train_scene.instantiate()
	
	train_instance.connect("loop_end", Callable(self, "_on_loop_end"))
	activator.connect("body_entered", Callable(self, "_on_activator_entered"))
	
	gate_end.position.x = gate_start.position.x
	train_instance.global_position = gate_start.global_position
	train_instance.mask_height = gate_end.position.y - gate_start.position.y
	add_child(train_instance)
	
func _on_activator_entered(body):
	if is_activator_on or not body is CharacterBody2D:
		return
	
	gate_start.get_node("AnimationPlayer").play("start")
	is_activator_on = true
	$Delay.one_shot = true
	$Delay.start()
	
func _on_loop_end():
	gate_start.get_node("AnimationPlayer").play("end")
	is_activator_on = false
	$Delay.one_shot = false

func _on_delay_timeout():
	train_instance.drive_loop_start()
