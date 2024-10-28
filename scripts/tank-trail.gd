extends Line2D

@export var tank: Tank 

var length = 50
var point: Vector2

func _ready():
	update_color()

func update_color():
	var color: Color = tank.tank_color
	
	var new_gradient: Gradient = Gradient.new()

	new_gradient.set_color(0, Color(color.r,color.g,color.b, 0))
	new_gradient.set_color(1, Color(color.r,color.g,color.b, 0.3))
	
	gradient = new_gradient

func _process(_delta):
	global_position = Vector2.ZERO
	point = tank.global_position
	
	add_point(point)
	
	while get_point_count() > length:
		remove_point(0)
