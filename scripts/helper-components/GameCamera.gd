extends Camera2D
class_name GameCamera

var offset_vector := Vector2.ZERO

var shake_vector := Vector2.ZERO
var shake_intensity := 0.0
var shake_interpolation := 1

var shake_nodes = {"intensity": {}, "interpolation": {}}

func _ready():
	Global.Game.cameras.push_front(self)

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
	shake_vector -= (shake_vector + shake_blunt) / shake_interpolation
	
	position = shake_vector + offset_vector

func _exit_tree():
	Global.Game.cameras.erase(self)
