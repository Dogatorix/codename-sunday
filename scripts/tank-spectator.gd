extends Marker2D

@export var camera: Camera2D
@export var animation_player: AnimationPlayer
@export var location_pulse: AnimationPlayer
@export var ready_audio: AudioStreamPlayer
@export var zoom_audio: AudioStreamPlayer

@export var tank_scene: PackedScene

var velocity: Vector2

var acceleration = 100
var friction = 50
var speed_normal := 900

var camera_zoom := 0.7

var is_client := true
var wait_time := 10.0

var timer_finished := false

# this is really stupid but idc
var tween1: Tween
var tween2: Tween

func _ready():
	if not is_client:
		queue_free()
		return
	
	Global.Game.Overlay.show_bars()
	
	get_tree().call_group("spawn_locations", "show_location")
	
	camera.zoom = Vector2(camera_zoom, camera_zoom)
	tween1 = Global.tween(self, "camera_zoom", .7, 2)
	tween2 = Global.tween(camera, "zoom", Vector2(0.7, 0.7), 2)
	
	if Global.is_mobile:
		Global.Game.Mobile.enable_spectator_controls()
	
func _process(delta):
	wait_time -= delta
	var speed: int
	
	if int(wait_time) > 0:
		%Time.text = "Respawning in %s seconds" % [int(wait_time)]
	elif not selected_location and not timer_finished:
		timer_finished = true
		animation_player.play("text_pulse")
		%Time.text = "Select respawning location"
	elif selected_location and not timer_finished:
		timer_finished = true
		restart_animation()
	
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
		camera_zoom = clamp(camera_zoom, 0.3, 1.5)
		update_camera_zoom()
		
	if Input.is_action_just_pressed("spectator_zoomout"):
		if camera_zoom > 0.3:
			zoom_audio.play()
		camera_zoom -= 0.3
		camera_zoom = clamp(camera_zoom, 0.3, 1.5)
		update_camera_zoom()
	
	if input_vector != Vector2.ZERO and Global.Game.active_input:
		input_vector = input_vector.normalized() * speed * delta
		velocity = velocity.move_toward(input_vector, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	global_position += velocity
	
	$MouseArea.global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("click") and location_in_area and not location_in_area == selected_location:
		if selected_location:
			selected_location.unclick()
		
		ready_audio.pitch_scale = 1 + randf_range(0.06, -0.06)
		ready_audio.play()
		selected_location = location_in_area
		selected_location.click()
		
		if timer_finished:
			restart_animation()
			
		%Location.text = "Selected: Location " + str(selected_location.index)
		location_pulse.play("pulse")
			
func update_camera_zoom():
	if tween1 or tween2:
		tween1.kill()
		tween2.kill()
	
	Global.tween(camera, "zoom", Vector2(camera_zoom, camera_zoom), .5)

var location_in_area: SpawnLocation
var selected_location: SpawnLocation

func _area_entered(area):	
	if not area is SpawnLocation or area == selected_location:
		return
	
	area.focus()
	location_in_area = area

func _area_exited(area):
	if not area is SpawnLocation or area == selected_location:
		return

	area.unfocus()
	location_in_area = null

const respawn_offset = 100

func restart_animation():
	%Time.text = "Respawning..."
	Global.fade_in()
	Global.connect("fade_in_complete", restart)

func restart():
	Global.disconnect("fade_in_complete", restart)
	Global.Game.spawn_location = selected_location
	selected_location.unclick()
	var tank_instance: Tank = tank_scene.instantiate()
	tank_instance.tank_id = Enums.TANKS.BASIC
	tank_instance.is_client = true
	
	var position_offset = Vector2(randi_range(respawn_offset, -respawn_offset), randi_range(respawn_offset, -respawn_offset))
	
	get_tree().call_group("spawn_locations", "hide_location")
	get_tree().current_scene.add_child(tank_instance)
	tank_instance.global_position = selected_location.global_position + position_offset
	queue_free()
