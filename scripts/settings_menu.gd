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
	%GodMode.button_pressed = Settings.client_god_mode
	%InfiniteMana.button_pressed = Settings.infinite_mana
	%NoClip.button_pressed = Settings.client_noclip
	%SpawnWithAI.button_pressed = Settings.spawn_with_ai
	%AIIgnoresClient.button_pressed = Settings.ai_ignore_client
	%ZoomSlider.value = Settings.sandbox_custom_zoom
	_on_zoom_slider_value_changed(Settings.sandbox_custom_zoom)
	
func _on_volume_update(value, index):
	AudioServer.set_bus_volume_db(index, linear_to_db(value))

func _on_run_sounds_toggled(toggled_on):
	Settings.run_sounds = toggled_on
	
	var tanks: Array[Node] = get_tree().get_nodes_in_group("tank")
	if tanks.size() > 0:
		for tank in tanks:
			tank.behaviour(Enums.COMPONENTS.MOVEMENT).setup_run_sounds()


func _on_god_mode_toggled(toggled_on):
	Settings.client_god_mode = toggled_on

func _on_infinite_mana_toggled(toggled_on):
	Settings.infinite_mana = toggled_on

func _on_no_clip_toggled(toggled_on):
	Settings.client_noclip = toggled_on
	
	if Global.Game:
		if Global.Game.gamemode == Enums.GAMEMODES.SANDBOX and Global.Game.client != null:
			if toggled_on:
				Global.Game.client.disable_collision()
			else:
				Global.Game.client.enable_collision()
	
func _on_disable_tank_ai_toggled(toggled_on):
	Settings.spawn_with_ai = toggled_on

func _on_ai_ignores_client_toggled(toggled_on):
	Settings.ai_ignore_client = toggled_on

func _on_zoom_slider_value_changed(value: float) -> void:
	if Global.Game != null:
		if Global.Game.client != null:
			Global.tween(Global.Game.client.camera, "zoom", Vector2(value, value), 0.5)
	Settings.sandbox_custom_zoom = value
	%ZoomSliderDisplay.text = "x" + str(value - 0.1).rpad(2,".0")
