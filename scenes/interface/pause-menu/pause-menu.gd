extends CanvasLayer

@export var settings_scene: PackedScene

signal destroy_menu()

var is_restarting: bool

const gamemode_texts: Dictionary = {
	Enums.GAMEMODES.SANDBOX: "Gamemode - The Sandbox",
	Enums.GAMEMODES.MACHINE_TRAINING: "Gamemode - Machine Training",
	Enums.GAMEMODES.LOBBY: "The Lobby"
}

func _ready():
	%GamemodeText.text = gamemode_texts[Global.Game.gamemode]
	
	if Global.Game.gamemode == Enums.GAMEMODES.SANDBOX:
		if Global.Game.Sandbox.move_instance != null:
			Global.Game.Sandbox.move_instance.queue_free()
		if Global.Game.Sandbox.spawn_instance != null:
			Global.Game.Sandbox.spawn_instance.queue_free()

func _process(_delta):
	%TimeSpent.text = seconds_to_clock(int(Global.Game.time_spent))

func seconds_to_clock(seconds):
	var minutes = floor(seconds / 60)
	
	var second_string = ""
	if (seconds % 60 < 10):
		second_string += "0" 
	second_string += str(seconds % 60)

	return str(minutes).lpad(2,"0") + ":" + second_string
	
func hide_menu():
	$AnimationPlayer.play("fade_away")
	if not settings_instance == null:
		settings_instance.close()
	
	await $AnimationPlayer.animation_finished
	destroy_menu.emit()

func _on_restart_pressed():
	if is_restarting:
		return
		
	is_restarting = true
		
	Global.Game.Sandbox.restart_sandbox()

func _on_leave_pressed():
	if is_restarting:
		return
		
	is_restarting = true
	
	Global.Game.quit_to_menu()

var settings_instance: Control
func _on_settings_pressed():	
	if settings_instance == null:
		add_settings()
	else:
		if settings_instance.is_closing:
			settings_instance = null
			add_settings()
			return
		settings_instance.close()
		settings_instance = null

func add_settings():
	settings_instance = settings_scene.instantiate()
	add_child(settings_instance)
	settings_instance.size = Vector2(817, 605)
	settings_instance.global_position = Vector2(355, 800)
