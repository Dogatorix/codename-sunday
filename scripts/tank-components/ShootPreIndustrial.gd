extends TankBehaviourComponent
class_name ShootPreIndustrial

@onready var tank = data_node.tank
@export var sprite_node: Node2D

var prevent_shoot := false
var can_shoot := true
var init_can_shoot := false

@export var bullet_scene: PackedScene

@export var bullet_speed := 500.0
@export var bullet_size := 1.0
@export var bullet_damage := 1.0
@export var bullet_penetration := 1

var input_condition: bool
var shoot_condition: bool

func _process(_delta):
	input_condition = (Input.is_action_pressed("shoot") and Global.device == Global.DEVICE.DESKTOP) \
	or Input.is_action_pressed("shoot_mobile")
	
	shoot_condition = input_condition and can_shoot \
	and Global.Game.active_input and tank.is_client and not prevent_shoot and init_can_shoot

func summon_bullet(target_position: Vector2):
	var bullet_instance: BasicBullet = bullet_scene.instantiate()
	
	bullet_instance.tank = tank
	bullet_instance.direction = sprite_node.rotation_degrees - 90
	bullet_instance.color = tank.tank_color
	
	bullet_instance.speed = bullet_speed
	bullet_instance.damage = bullet_damage
	bullet_instance.size = bullet_size
	bullet_instance.penetration = bullet_penetration
		
	tank.add_sibling(bullet_instance)
	bullet_instance.global_position = target_position

func disable_shoot():
	init_can_shoot = false

func enable_shoot():
	init_can_shoot = true
