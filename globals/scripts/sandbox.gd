extends Node

@export var spawn_cursor_scene: PackedScene
@export var move_cursor_scene: PackedScene

var spawn_mode := false
var spawn_instance = null

var move_mode := false
var move_instance = null

var paused: bool:
	get:
		return Global.Game.paused

func _ready():
	Global.Game.connect("menu_updated", _on_menu_update)
	Global.connect("restarted", _on_menu_restarted)

	var tank: Tank = Global.Game.create_tank()	
	tank.tank_id = Enums.TANKS.BASIC
	tank.tank_color = Global.Game.TANK_DEFAULT_COLORS.pick_random()
	tank.is_client = true
	get_tree().current_scene.add_child(tank)
	print(get_tree().current_scene)
	print(tank)

func _on_menu_update(_mode):
	spawn_mode = false
	update_spawner()
	move_mode = false
	update_move()	
	
func _on_menu_restarted():
	spawn_mode = false

func _process(_delta):
	if Input.is_action_just_pressed("spawn-mode-toggle") and not paused and Global.Game.client:
		spawn_mode = !spawn_mode
		update_spawner()
			
	if Input.is_action_just_pressed("move-mode-toggle") and not paused and Global.Game.client:
		move_mode = !move_mode
		update_move()		
		
func update_spawner():
	if spawn_mode:
		move_mode = false
		update_move()
		spawn_instance = spawn_cursor_scene.instantiate()
		get_tree().current_scene.add_child(spawn_instance)
	else:
		if spawn_instance != null:
			spawn_instance.queue_free()

func update_move():
	if move_mode:
		spawn_mode = false
		update_spawner()
		move_instance = move_cursor_scene.instantiate()
		get_tree().current_scene.add_child(move_instance)
	else:
		if move_instance != null:
			move_instance.queue_free()
