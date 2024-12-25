extends Node

@export var Overlay: CanvasLayer
@export var PauseMenu: CanvasLayer
@export var sandbox_scene: PackedScene

enum GAMEMODES {
	SANDBOX,
	ADVANCED_TRAINING
}

signal restarted()
signal menu_updated(mode: bool)

var gamemode: GAMEMODES = GAMEMODES.ADVANCED_TRAINING

var clients: Array[Tank] = []
var cameras: Array[GameCamera] = []


var game_camera: GameCamera = null:
	get:
		if cameras.size() == 0:
			return null
		return cameras[0]

var client: Tank:
	get():
		return clients[0]

var	active_input := true

func make_external(node: Node, root, clone: Node = null):
	var dublicate: Node
	
	if clone:
		dublicate = clone
	else:
		dublicate = node.duplicate()
	
	dublicate.external = false
	root.add_sibling.call_deferred(dublicate)
	dublicate.global_position = node.global_position
	node.queue_free()
	
func timeout_destroy(target: Node, duration: float):
	var timer: Timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = true
	target.add_child(timer)
	timer.connect("timeout", Callable(target, "queue_free"))

var paused := false

func update_menu():
	if paused:
		menu_updated.emit(true)
		PauseMenu.show_menu()
		active_input = false
	else:
		menu_updated.emit(false)
		PauseMenu.hide_menu()
		active_input = true
		
var Sandbox: Node 
func _ready():
	if gamemode == GAMEMODES.SANDBOX:
		Sandbox = sandbox_scene.instantiate()
		add_child(Sandbox)
	
func _process(_delta):
	if Input.is_action_just_pressed("fun-menu-show"):
		paused = !paused
		Global.Game.update_menu()
