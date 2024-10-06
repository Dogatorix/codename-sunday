extends Marker2D

@export var camera: Camera2D

var velocity: Vector2

var acceleration = 100
var friction = 50
var speed_normal := 900

var camera_zoom := 0.7

var is_client := false

func _ready():
	if not is_client:
		queue_free()
		return
		
	camera.zoom = Vector2(camera_zoom, camera_zoom)

func _process(delta):
	var speed: int
	
	if not Input.is_action_pressed("spectator_speedup"):
		speed = speed_normal
	else:
		speed = speed_normal * 2.5
	
	var input_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if Input.is_action_just_pressed("spectator_zoomin"):
		camera_zoom += 0.3
		
	if Input.is_action_just_pressed("spectator_zoomout"):
		camera_zoom -= 0.3
		
	camera_zoom = clamp(camera_zoom, 0.3, 1.5)
	camera.zoom = camera.zoom.move_toward(Vector2(camera_zoom, camera_zoom), 3 * delta)
	
	if input_vector != Vector2.ZERO and Global.no_console:
		input_vector = input_vector.normalized() * speed * delta
		velocity = velocity.move_toward(input_vector, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	global_position += velocity
