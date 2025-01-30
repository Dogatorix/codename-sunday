extends Camera2D
class_name GameCamera

var offset_vector: Vector2
var camera_offset: Vector2

var shake_vector: Vector2
var shake_intensity := 0.0
var shake_interpolation := 1

var shake_nodes = {"intensity": {}, "interpolation": {}}

func _ready():
	Global.Game.cameras.push_front(self)

var shake_delta: Vector2

func _process(_delta):
	var max_intensity = shake_nodes.intensity.values().max()
	
	if max_intensity:
		shake_intensity = max_intensity
		var max_intensity_key = shake_nodes.intensity.find_key(max_intensity)
		shake_interpolation = shake_nodes.interpolation[max_intensity_key]
	else:
		shake_intensity = 0
	
	@warning_ignore("narrowing_conversion")
	var shake_blunt = Vector2(randi_range(-shake_intensity, shake_intensity), randi_range(-shake_intensity, shake_intensity))
	var shake_vector_first = shake_vector
	shake_vector -= (shake_vector + shake_blunt) / shake_interpolation
	
	offset = shake_vector + offset_vector + camera_offset
	shake_delta = shake_vector - shake_vector_first

func _exit_tree():
	Global.Game.cameras.erase(self)
