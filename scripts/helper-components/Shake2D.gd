extends Marker2D
class_name Shake2D

@export var shake_range := 0
@export var duration := -1.0
@export var one_shot := false
@export var auto_start := false
@export var intensity := 5.0
@export var intensity_decay := 0.0
@export var interpolation = 1
@export var external := false
@export var root: Node

@onready var id = randi_range(0, 100000)
@onready var max_intensity = intensity

func _ready():
	if not root:
		root = get_parent()
	
	if auto_start:
		start()

func start():
	auto_start = true
	intensity = max_intensity
	
	if external and one_shot:
		Global.make_external(self, root)
		return
	
	if duration > 0 and one_shot:
		var timer = Timer.new()
		timer.wait_time = duration
		add_child(timer)
		timer.connect("timeout", queue_free)
		timer.start()

func _process(delta):
	if not Global.game_camera or not auto_start:
		return
	
	var distance = (Global.game_camera.global_position - global_position).length()
	
	if distance <= shake_range:
		var relative_intensity = ((shake_range - distance) / 500) * intensity
		Global.game_camera.shake_nodes.intensity[id] = relative_intensity
		Global.game_camera.shake_nodes.interpolation[id] = interpolation
	else:
		Global.game_camera.shake_nodes.intensity.erase(id)
		Global.game_camera.shake_nodes.interpolation.erase(id)
		
	intensity -= intensity_decay * delta
	intensity = max(0, intensity)
	
func _exit_tree():
	if not Global.game_camera:
		return
		
	Global.game_camera.shake_nodes.intensity.erase(id)
	Global.game_camera.shake_nodes.interpolation.erase(id)
