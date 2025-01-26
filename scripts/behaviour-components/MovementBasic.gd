extends TankBehaviourComponent
class_name MovementBasic

var camera: GameCamera

@onready var tank_sprite: Node2D = %TankSprite

@export var speed: float = 550
@export var camera_offset_scale := 40

var can_look := true

const acceleration: float = 2500
const friction: float = 2000
const push_force: float = 80

var normal_velocity := Vector2.ZERO
var dash_velocity := Vector2.ZERO

var external_velocity := Vector2.ZERO

var external_velocity_decay := 0
var external_velocity_length := 0
var external_velocity_direction := 0.0

var input_vector := Vector2.ZERO

var can_move := true

var run_sounds: AudioStreamPlayer2D
var run_sounds_can_play: bool
func _setup_finished():
	if Settings.run_sounds:
		setup_run_sounds()

func setup_run_sounds():
	if run_sounds and not Settings.run_sounds:
		run_sounds.queue_free()
		run_sounds = null
		
	if run_sounds == null and Settings.run_sounds:
		var run_sounds_scene: PackedScene = load("res://scenes/graphics/run-sound.tscn")
		run_sounds = run_sounds_scene.instantiate()
		get_parent().add_sibling.call_deferred(run_sounds)
		await run_sounds.ready
		run_sounds.connect("finished", run_sounds.play)

func _process(delta):
	tank.move_and_slide()
	
	camera = tank.camera
	
	external_velocity = Vector2(1,0).rotated(external_velocity_direction) * external_velocity_length 
	external_velocity_length = max(0, external_velocity_length - (external_velocity_decay * delta) )
	
	if tank.is_client:
		input_vector = Vector2(
			Input.get_axis("move_left", "move_right"),
			Input.get_axis("move_up", "move_down")
		)
		
	
	if input_vector != Vector2.ZERO and Global.Game.active_input and can_move:
		normal_velocity = normal_velocity.move_toward(input_vector.normalized() * speed, acceleration * delta)
	else:
		normal_velocity = normal_velocity.move_toward(Vector2.ZERO, friction * delta)
	
	tank.velocity = normal_velocity + external_velocity + dash_velocity

	if tank_sprite and camera and can_look and not Global.is_mobile:
		rotate_tank_camera()
		camera_control()
		
	if Global.is_mobile:
		var joystick: VirtualJoystick = Global.Game.Mobile.direction_joystick
		var direction = joystick.output.angle()
		
		if joystick.is_pressed:
			rotate_tank(rad_to_deg(direction) + 90)
	
	if input_vector == Vector2.ZERO and not run_sounds == null:
		run_sounds.stop()
		run_sounds_can_play = true

func rotate_tank_camera():
	var mouse_position = tank.get_global_mouse_position() - camera.shake_vector
	var direction = (mouse_position - tank.global_position).normalized()
	var angle = atan2(direction.y, direction.x)
	var final_angle = rad_to_deg(angle) + 90
	
	tank_sprite.rotation_degrees = final_angle

func rotate_tank(degrees: float):
	tank_sprite.rotation_degrees = degrees 

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

func _input(event):
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right") or event.is_action_pressed("move_up") or event.is_action_pressed("move_down"):
		if run_sounds_can_play and run_sounds:
			run_sounds_can_play = false
			run_sounds.play(0)
