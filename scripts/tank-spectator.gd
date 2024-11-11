extends Marker2D

@export var camera: Camera2D
@export var animation_player: AnimationPlayer
@export var ready_audio: AudioStreamPlayer
@export var zoom_audio: AudioStreamPlayer

var velocity: Vector2

var acceleration = 100
var friction = 50
var speed_normal := 900

var camera_zoom := 0.7

var is_client := false
var can_respawn := false
var wait_time := 10.0

func _ready():
	if not is_client:
		queue_free()
		return
		
	camera.zoom = Vector2(camera_zoom, camera_zoom)
	%Lives.text = str(Global.player_lives) + " Lives remain"

func _process(delta):
	wait_time -= delta
	var speed: int
	
	if int(wait_time) > 0:
		%Time.text = "Respawning in %s seconds" % [int(wait_time)]
	elif not can_respawn:
		can_respawn = true
		animation_player.play("text_pulse")
		ready_audio.play()
		%Time.text = "Press R to respawn"
	
	if not Input.is_action_pressed("spectator_speedup"):
		speed = speed_normal
	else:
		speed = speed_normal * 2.5
	
	var input_vector = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	
	if Input.is_action_just_pressed("spectator_zoomin"):
		if camera_zoom < 1.5:
			zoom_audio.play()	
		camera_zoom += 0.3
		
	if Input.is_action_just_pressed("spectator_zoomout"):
		if camera_zoom > 0.3:
			zoom_audio.play()
		camera_zoom -= 0.3
		
	camera_zoom = clamp(camera_zoom, 0.3, 1.5)
	camera.zoom = camera.zoom.move_toward(Vector2(camera_zoom, camera_zoom), 3 * delta)
	
	if input_vector != Vector2.ZERO and Global.active_input:
		input_vector = input_vector.normalized() * speed * delta
		velocity = velocity.move_toward(input_vector, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	global_position += velocity
