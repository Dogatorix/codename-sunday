extends Node

@onready var gate_start: Node2D = get_node_or_null("TrainGateStart")
@onready var gate_end: Node2D = get_node_or_null("TrainGateEnd")
@onready var activator: Area2D = get_node_or_null("TrainActivator")

@export var train_scene: PackedScene
var train_instance: Node2D
var is_activator_on := false
var mask_height := 5000.0

func _ready():
	if !gate_start or !gate_end or !activator:
		push_error(str(self) + " Missing component(s)")
		queue_free()
		return
	
	train_instance = train_scene.instantiate()
	
	train_instance.connect("loop_end", _on_loop_end)
	activator.connect("body_entered", _on_activator_entered)
	
	gate_end.position.x = gate_start.position.x
	mask_height = gate_end.position.y - gate_start.position.y
	add_child(train_instance)
	train_instance.global_position = gate_start.global_position
	
func _on_activator_entered(body):
	if is_activator_on or not body is CharacterBody2D:
		return
	
	gate_start.get_node("AnimationPlayer").play("start")
	gate_start.get_node("StartupAudio").start()
	
	var activator_player = activator.get_node("AnimationPlayer")
	if activator_player.is_playing():
		activator_player.stop()
	activator_player.play("activate")
		
	activator.get_node("PressAudio").start()
	is_activator_on = true
	$Delay.one_shot = true
	$Delay.start()
	
func _on_loop_end():
	Console.append("test")
	gate_start.get_node("AnimationPlayer").play("end")
	$ButtonDelay.start()

func _on_delay_timeout():
	train_instance.drive_loop_start()

func _on_button_delay_timeout():
	activator.get_node("AnimationPlayer").play("back")
	is_activator_on = false
	$Delay.one_shot = false
	$ButtonDelay.stop()
