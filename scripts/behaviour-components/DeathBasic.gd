extends TankBehaviourComponent
class_name DeathBasic

var stats: StatsBasic

@export var spectator_scene: PackedScene
@export var death_scene: PackedScene

@onready var predeath_sound: Audio2D = %GiveUpSound
@onready var animation_player: AnimationPlayer = %SpriteAnimations

var is_dying := false

func _process(_delta):
	if Input.is_action_just_pressed("debug-1") and tank.is_client:
		instant_death()

func _setup_finished():
	stats = tank.behaviour(Enums.COMPONENTS.STATS)
	safety_check([stats, spectator_scene])
	stats.connect("health_change", _on_health_change)
		
func _on_health_change(health):
	if health > 0 or is_dying:
		return

	animation_player.play("death")
	
	if tank.is_client:
		Global.Game.Overlay.show_bars()
		
	if tank.is_client and Global.Game.upgrade_menu != null:
		Global.Game.upgrade_menu.close()
	
	var timer: Timer = Timer.new()
	timer.wait_time = 0.35
	timer.autostart = true
	timer.connect("timeout", death)
	add_child(timer)
	
	predeath_sound.start()

func death():
	var death_instance = death_scene.instantiate()
	death_instance.modulate = tank.tank_color.darkened(0.3)
	tank.add_sibling(death_instance)
	death_instance.global_position = tank.global_position
	tank.queue_free()
	
	if tank.is_client: 
		var spectator_instance = spectator_scene.instantiate()
		spectator_instance.is_client = tank.is_client
		spectator_instance.camera_zoom = tank.default_zoom
		tank.add_sibling.call_deferred(spectator_instance)
		
		await spectator_instance.ready
		spectator_instance.global_position = tank.global_position

func instant_death():	
	if tank.is_client:
		if Settings.client_god_mode:
			return
		Global.Game.Overlay.show_bars()
	death()
