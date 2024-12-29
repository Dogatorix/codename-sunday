extends CanvasLayer

@export var upgrades: Array[Enums.TANKS]
@export var splash_button_scene: PackedScene
@export var upgrade_tier: Enums.TANK_TIERS

@onready var center = get_viewport().size / 2


const button_size := 250

func _ready():
	%TierText.text = "Upgrade to Tier " + str(upgrade_tier)
	
	var camera: GameCamera = Global.Game.client.camera
	Global.tween(camera, "offset", Vector2(0, -60), 1)

	var upgrade_size = upgrades.size()
	
	for upgrade in upgrades:
		var upgrade_index = upgrades.find(upgrade)
		var splash_button_instance = splash_button_scene.instantiate()
		
		
		var target_position: Vector2
		target_position.x = center.x + ((upgrade_size - upgrade_index) * button_size) \
		- (button_size / 2.0) - (button_size * upgrade_size / 2.0)
		target_position.y = $Buttons.position.y
		
		splash_button_instance.tank_id = upgrade
		splash_button_instance.position = Vector2(center.x, target_position.y)
		
		Global.tween(splash_button_instance, "position", target_position, 1)
		
		$Buttons.add_child(splash_button_instance)
		splash_button_instance.connect("on_click", close)

func close():
	var camera: GameCamera = Global.Game.client.camera
	Global.tween(camera, "offset", Vector2(0, 0), 1)

	$AnimationPlayer.play("destroy")
	for button in $Buttons.get_children():
		button.play_click_anim()
