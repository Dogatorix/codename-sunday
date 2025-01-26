extends Control

@onready var init_scale := scale

var is_closing: bool

func open():
	scale.y = 0
	Global.tween(self, "scale", init_scale, .5)

func close():
	is_closing = true
	Global.tween(self, "scale", Vector2(init_scale.x, 0), .5)
	%CloseDelay.start()
	await %CloseDelay.timeout
	queue_free()

func _ready():
	open()
	%RunSounds.button_pressed = Settings.run_sounds
	
func _on_volume_update(value, index):
	AudioServer.set_bus_volume_db(index, linear_to_db(value))

func _on_run_sounds_toggled(toggled_on):
	Settings.run_sounds = toggled_on
	
	var tanks: Array[Node] = get_tree().get_nodes_in_group("tank")
	if tanks.size() > 0:
		for tank in tanks:
			tank.behaviour(Enums.COMPONENTS.MOVEMENT).setup_run_sounds()
