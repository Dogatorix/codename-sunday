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

var velocity := Vector2.ZERO
var dash_velocity := Vector2.ZERO
var input_vector := Vector2.ZERO

func on_process(delta):
	tank.move_and_slide()
	camera = tank.camera
	
	input_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if input_vector != Vector2.ZERO and Global.no_console:
		input_vector = input_vector.normalized() * speed
		velocity = velocity.move_toward(input_vector, acceleration * delta) + dash_velocity
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	tank.velocity = velocity
	
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
