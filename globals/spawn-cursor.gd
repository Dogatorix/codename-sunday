extends Node2D

@export var spawn_scenes: Array[PackedScene]

var spawn_names := [
	"Tank - Basic",
	"Tank - Destroy",
	"Tank - Crush",
	"Tank - Assault",
	"Object - Oil Canister",
	"CHARTER REVOKED"
]

var selected_scene: PackedScene
var selection_pointer := 0

func _ready():
	update_scene()

func _process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("spawn-cursor-next"):
		selection_pointer += 1
		update_scene()
	if Input.is_action_just_pressed("spawn-cursor-previous"):
		selection_pointer -= 1
		update_scene()
		
	if Input.is_action_just_pressed("spawn-cursor-summon"):
		var scene_instance = selected_scene.instantiate()
		get_tree().current_scene.add_child(scene_instance)
		scene_instance.global_position = global_position
	
func update_scene():
	selection_pointer = clamp(selection_pointer, 0, spawn_scenes.size() - 1)
	selected_scene = spawn_scenes[selection_pointer]
	%SummonLabel.text = "Selected: " + spawn_names[selection_pointer]
