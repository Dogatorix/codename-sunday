extends Node
class_name GameGlobal

@export var Overlay: CanvasLayer

@export var sandbox_scene: PackedScene
@export var mobile_controls_scene: PackedScene

@export var player_interface_scene: PackedScene
@export var tank_upgrade_scene: PackedScene
@export var pause_menu_scene: PackedScene

@export var tank_scenes: Array[TankScene]

@export var gamemode: Enums.GAMEMODES = Enums.GAMEMODES.SANDBOX

const TANK_DEFAULT_COLORS: Array[Color] = [
	Color.RED,
	Color.BLUE,
	Color.GREEN,
	Color.AQUA,
	Color.CYAN,
	Color.ORANGE,
	Color.ORANGE_RED,
	Color.YELLOW,
	Color.PURPLE,
	Color.HOT_PINK
]

signal restarted()
signal menu_updated(mode: bool)

var clients: Array[Tank] = []
var cameras: Array[GameCamera] = []
var spawn_location: SpawnLocation

var game_camera: GameCamera = null:
	get:
		if cameras.size() == 0:
			return null
		return cameras[0]

var client: Tank:
	get():
		if clients.size() == 0:
			return null
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

var PauseMenu: CanvasLayer
func update_menu():
	if paused:
		active_input = false
		if PauseMenu:
			PauseMenu.queue_free()
			PauseMenu = null
		PauseMenu = pause_menu_scene.instantiate()
		add_child(PauseMenu)
	elif PauseMenu != null:
		menu_updated.emit(false)
		PauseMenu.hide_menu()
		await PauseMenu.destroy_menu
		PauseMenu.queue_free()
		PauseMenu = null
		active_input = true
		
var Sandbox: SandboxGlobal
var Mobile: Node

var path_points: Array[Vector2]	

func _ready():
	var path_points_node: TileMapLayer = get_tree().get_first_node_in_group("path_points")
	
	for cell in path_points_node.get_used_cells():
		path_points.push_front(path_points_node.map_to_local(cell))
		
	path_points_node.queue_free()
	
	if Global.is_mobile:
		Mobile = mobile_controls_scene.instantiate()
		add_child(Mobile)
		
	if gamemode == Enums.GAMEMODES.SANDBOX:
		Sandbox = sandbox_scene.instantiate()
		add_child(Sandbox)
		
var player_interface: CanvasLayer

func add_player_interface():
	player_interface = player_interface_scene.instantiate()
	client.add_child(player_interface)
	
var upgrade_menu: CanvasLayer

func add_upgrade_menu(upgrades: Array[Enums.TANKS], tier: Enums.TANK_TIERS):
	upgrade_menu = tank_upgrade_scene.instantiate()
	upgrade_menu.upgrades = upgrades
	upgrade_menu.upgrade_tier = tier
	client.add_child(upgrade_menu)
	
func quit_to_menu():
	Global.fade_in()
	await Global.fade_in_complete
	Global.switch_current_scene("res://menu/menu.tscn")
	Global.Game.queue_free()

var time_spent = 0.0

func _process(delta):
	time_spent += delta
	
	if Input.is_action_just_pressed("fun-menu-show"):
		paused = !paused
		Global.Game.update_menu()
		
func input_autherization(tank):
	return active_input and tank.is_client
	
@export var tank_scene: PackedScene
func create_tank():
	var tank_instance: Tank = tank_scene.instantiate()
	return tank_instance
