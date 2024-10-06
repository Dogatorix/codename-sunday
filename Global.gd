extends Node

var clients: Array[Tank] = []
var cameras: Array[GameCamera] = []

var game_camera: GameCamera = null:
	get:
		if cameras.size() == 0:
			return null
		return cameras[0]

var	no_console := true

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
	dublicate.global_position = node.global_position
	node.get_parent().add_sibling.call_deferred(dublicate)
	node.queue_free()
	
func timeout_destroy(target: Node, duration: float):
	var timer: Timer = Timer.new()
	timer.wait_time = duration
	timer.autostart = true
	target.add_child(timer)
	timer.connect("timeout", Callable(target, "queue_free"))
	
