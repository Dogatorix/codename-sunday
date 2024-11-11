extends Node

var clients: Array[Tank] = []
var cameras: Array[GameCamera] = []

var player_lives := 5

var game_camera: GameCamera = null:
	get:
		if cameras.size() == 0:
			return null
		return cameras[0]

var client: Tank:
	get():
		return Global.clients[0]

var	active_input := true

var player_color: Color:
	set(value):
		if clients.size() > 0:
			clients[0].tank_color = value
			clients[0].core_sprite.modulate = value
			clients[0].get_node("TankTrail").update_color()
			player_color = value

const CORE_REQUIREMENT = {
	1: 1,
	2: 500,
	3: 2000,
	4: 8000,
	5: 25000,
}

var PRELOADS = {
	"energy-square": load("res://scenes/containers/energy-square.tscn"),
	"energy-triangle": load("res://scenes/containers/energy-triangle.tscn"),
	"energy-pentagon": load("res://scenes/containers/energy-pentagon.tscn"),
	"energy-octagon": load("res://scenes/containers/energy-octagon.tscn"),
}	

func make_external(node: Node, clone: Node = null):
	var dublicate: Node
	
	if clone:
		dublicate = clone
	else:
		dublicate = node.duplicate()
	
	dublicate.external = false
	node.get_parent().add_sibling.call_deferred(dublicate)
	dublicate.global_position = node.global_position
	node.queue_free()
	
func timeout_destroy(target: Node, duration: float):
	var timer: Timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = true
	target.add_child(timer)
	timer.connect("timeout", Callable(target, "queue_free"))

var spawn_mode := false
var spawn_instance = null
@onready var spawn_cursor_scene: PackedScene = load("res://globals/spawn-cursor.tscn")

var move_mode := false
var move_instance = null
@onready var move_cursor_scene: PackedScene = load("res://globals/move-cursor.tscn")

var paused := false

func _process(_delta):
	if Input.is_action_just_pressed("spawn-mode-toggle") and not paused:
		spawn_mode = !spawn_mode
		update_spawner()
			
	if Input.is_action_just_pressed("move-mode-toggle") and not paused:
		print('test')
		move_mode = !move_mode
		update_move()		
	
	if Input.is_action_just_pressed("restart") and active_input:
		get_tree().reload_current_scene()
		spawn_mode = false
		
	if Input.is_action_just_pressed("fun-menu-show"):
		paused = !paused
		update_menu()
		
func update_spawner():
	if spawn_mode:
		move_mode = false
		update_move()
		spawn_instance = spawn_cursor_scene.instantiate()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		get_tree().current_scene.add_child(spawn_instance)
	else:
		if spawn_instance != null:
			spawn_instance.queue_free()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func update_move():
	if move_mode:
		print("show")
		spawn_mode = false
		update_spawner()
		move_instance = move_cursor_scene.instantiate()
		get_tree().current_scene.add_child(move_instance)
	else:
		if move_instance != null:
			move_instance.queue_free()

func update_menu():
	if paused:
		spawn_mode = false
		update_spawner()
		move_mode = false
		update_move()
		
		FunMenu.show_menu()
		active_input = false
	else:
		FunMenu.hide_menu()
		active_input = true

func _ready():
	if not FileAccess.file_exists("res://coconut.png"):
		get_parent().fuck_you()	
		
