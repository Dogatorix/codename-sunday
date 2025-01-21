extends CanvasLayer

signal destroy_menu()

var is_restarting: bool

const gamemode_texts: Dictionary = {
	Enums.GAMEMODES.SANDBOX: "Gamemode - The Sandbox",
	Enums.GAMEMODES.MACHINE_TRAINING: "Gamemode - Machine Training"
}

func _ready():
	%GamemodeText.text = gamemode_texts[Global.Game.gamemode]

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
	
