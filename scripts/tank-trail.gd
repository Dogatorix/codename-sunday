extends Line2D

@export var tank: Tank 

var length = 50
var point: Vector2

func _ready():
	update_color()

func update_color():
	var color: Color = tank.tank_color
	if gradient.get_point_count() >= 2:
		gradient.remove_point(0)
		gradient.remove_point(1)
	gradient.add_point(0, Color(color.r,color.g,color.b, 0))
	gradient.add_point(1, Color(color.r,color.g,color.b, 0.3))

func _process(_delta):
	global_position = Vector2.ZERO
	point = get_parent().global_position
	
	add_point(point)
	
	while get_point_count() > length:
		remove_point(0)
