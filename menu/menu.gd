extends Node2D
# I know the main menu code is a bit messy but ahh i dont care at this point

@onready var menu_start_button = %MenuStartButton

@export var settings_scene: PackedScene

func _ready():
	menu_start_button.disable()
	
	%UserLabel.text = "User: " + Global.username
	
	if Global.is_logged_in:
		%Dropdown.queue_free()
		%MenuMusic.play()
		enable_menu_buttons()
		Global.fade_out()
	else:
		%LightHumming.play()
		%MenuAnimations.play("init")

func _on_menu_button_pressed():
	Global.username = %NameEdit.text_value

	menu_start_button.disabled = true
	%MenuAnimations.play("open")
	%UserLabel.text = "User: " + Global.username
	Global.is_logged_in = true

	enable_menu_buttons()

func enable_menu_buttons():
	#%MachineTraining.enable()
	%Settings.enable()
	%TheSandbox.enable()
	%QuitGame.enable()

func menu_cleanup():
	%LightHumming.queue_free()
	%DropdownBottom.queue_free()
	%DropdownTop.queue_free()
	menu_start_button.queue_free()

func _on_menu_input_text_changed(new_text):
	if not new_text == "" and menu_start_button.disabled:
		menu_start_button.enable() 
	elif new_text == "" and not menu_start_button.disabled:
		menu_start_button.disable()

func _on_quit_game_pressed():
	Global.fade_in()
	await Global.fade_in_complete
	quit_game()

func quit_game():
	get_tree().quit()

func _on_sandbox_pressed():
	disable_menu_buttons()	
	Global.fade_in()
	await Global.fade_in_complete
	
	var sandbox_scene: PackedScene = load("res://scenes/maps/sandbox.tscn")
	get_tree().current_scene.queue_free()

	var instances_scene := sandbox_scene.instantiate()
	get_tree().root.add_child(instances_scene)
	get_tree().current_scene = instances_scene
	
	Global.create_game(Enums.GAMEMODES.SANDBOX)

func disable_menu_buttons():
	%TheSandbox.disable()
	%QuitGame.disable()
	%MachineTraining.disable()

@onready var menu_buttons_container_pos_init = %MenuButtonsContainer.global_position
@onready var go_back_button_pos_init = %GoBack.global_position
var settings_instance: Control
func _on_settings_pressed():
	if settings_instance != null:
		settings_instance.queue_free()
	Global.tween(%MenuButtonsContainer, "global_position", Vector2(2200, menu_buttons_container_pos_init.y), 1)
	Global.tween(%GoBack, "global_position", Vector2(1250, go_back_button_pos_init.y), 1)
	settings_instance = settings_scene.instantiate()
	settings_instance.size = Vector2(900, 700)
	settings_instance.position = Vector2(150, 100)
	add_child(settings_instance)
	%GoBack.enable()
	%GoBack.modulate = Color("0097fd")
	#this is an awful implementation but i dont know why theyre white so whatever

func _on_go_back_pressed():
	settings_instance.close()
	Global.tween(%MenuButtonsContainer, "global_position", menu_buttons_container_pos_init, 1)
	Global.tween(%GoBack, "global_position", go_back_button_pos_init, 1)
	%Settings.enable()
	%Settings.modulate = Color("0097fd")
