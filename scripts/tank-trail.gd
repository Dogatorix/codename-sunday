extends Line2D

@export var length = 50
@export var decay: float = 2

var point: Vector2

func _process(_delta):
	global_position = Vector2.ZERO
	point = get_parent().global_position
	
	add_point(point)
	
	while get_point_count() > length:
		remove_point(0)
		
	modulate = Color(1, 1, 1, decay)
	decay = max(0, decay - 0.025)
	
	if decay == 0:
		queue_free()
