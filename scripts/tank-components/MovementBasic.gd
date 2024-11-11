extends TankComponent
class_name MovementBasic

const component_name = "movement"

var camera: GameCamera
@export_group("Camera")
@export var camera_offset_scale := 40
@export var can_look := true

@export_group("General")
@export var speed: float = 1000
@export var acceleration: float = 2500
@export var friction: float = 2000
@export var push_force: float = 80

@export_group("References")
@export var tank_sprite: Node2D

var normal_velocity := Vector2.ZERO
var dash_velocity := Vector2.ZERO

var external_velocity := Vector2.ZERO

var external_velocity_decay := 0
var external_velocity_length := 0
var external_velocity_direction := 0.0

var input_vector := Vector2.ZERO

func on_process(delta):
	tank.move_and_slide()
	camera = tank.camera
	
	external_velocity = Vector2(1,0).rotated(external_velocity_direction) * external_velocity_length 
	external_velocity_length = max(0, external_velocity_length - (external_velocity_decay * delta) )
	
	if tank.is_client:
		input_vector = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)
	
	if input_vector != Vector2.ZERO and Global.active_input:
		normal_velocity = normal_velocity.move_toward(input_vector.normalized() * speed, acceleration * delta)
	else:
		normal_velocity = normal_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	tank.velocity = normal_velocity + external_velocity + dash_velocity
	
	for i in tank.get_slide_collision_count():
		var c = tank.get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)

	if tank_sprite and camera and can_look:
		rotate_tank()
		camera_control()

func rotate_tank():
	var mouse_position = tank.get_global_mouse_position() - camera.shake_vector
	var direction = (mouse_position - tank.global_position).normalized()
	var angle = atan2(direction.y, direction.x)
	var final_angle = rad_to_deg(angle) + 90
	
	tank_sprite.rotation_degrees = final_angle

func camera_control():
	var distance = (tank.get_global_mouse_position() - tank.global_position) / camera_offset_scale
	camera.offset_vector = distance

func apply_external_velocity(direction: float, power: int, decay: int):
	normal_velocity = Vector2.ZERO
	external_velocity = Vector2.ZERO
	external_velocity_direction = deg_to_rad(direction)
	external_velocity_length = power
	external_velocity_decay = decay

func reset_external_velocity():
	external_velocity_length = 0
	external_velocity = Vector2.ZERO
