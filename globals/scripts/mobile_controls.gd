extends CanvasLayer

@export var direction_joystick: VirtualJoystick
@export var tank_controls: Array[Node]
@export var spectator_controls: Array[Node] 

func disable_nodes(arr: Array[Node]):
	for node in arr:
		node.visible = false
		node.disabled = true

func enable_nodes(arr: Array[Node]):
	for node in arr:
		node.visible = true
		node.disabled = false

func _ready():
	enable_tank_controls()

func enable_tank_controls():
	enable_nodes(tank_controls)
	disable_nodes(spectator_controls)
	
func enable_spectator_controls():
	disable_nodes(tank_controls)
	enable_nodes(spectator_controls)
