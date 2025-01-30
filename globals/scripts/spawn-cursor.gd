extends Node2D

@export var spawn_scenes: Array[StringScene]

var selected_scene: PackedScene
var selection_pointer := 0

func _ready():
	update_scene()
	global_position = get_global_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Global.Game.client.connect("tree_exiting", queue_free)

func _process(_delta):
	Global.Game.client.behaviour(Enums.COMPONENTS.SHOOT).prevent_shoot = true
	
	global_position = get_global_mouse_position()
	if Input.is_action_just_pressed("spawn-cursor-next"):
		selection_pointer += 1
		update_scene()
	if Input.is_action_just_pressed("spawn-cursor-previous"):
		selection_pointer -= 1
		update_scene()
		
	if Input.is_action_just_pressed("spawn-cursor-summon"):
		var scene_name = spawn_scenes[selection_pointer].name
		var scene_instance = selected_scene.instantiate()
		
		if scene_name == "Tank - Basic":
			scene_instance.tank_id = Enums.TANKS.BASIC
		if scene_name == "Tank - Assault":
			scene_instance.tank_id = Enums.TANKS.ASSAULT
		if scene_name == "Tank - Destroy":
			scene_instance.tank_id = Enums.TANKS.DESTROY
		if scene_name == "Tank - Crush":
			scene_instance.tank_id = Enums.TANKS.CRUSH
			
		if scene_instance is Tank:
			scene_instance.tank_color = Global.Game.TANK_DEFAULT_COLORS.pick_random()
			
		get_tree().current_scene.add_child(scene_instance)
		scene_instance.global_position = global_position
	
func update_scene():
	selection_pointer = clamp(selection_pointer, 0, spawn_scenes.size() - 1)
	selected_scene = spawn_scenes[selection_pointer].scene
	%SummonLabel.text = "Selected: " + spawn_scenes[selection_pointer].name

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Global.Game.client != null:
		Global.Game.client.behaviour(Enums.COMPONENTS.SHOOT).prevent_shoot = false
