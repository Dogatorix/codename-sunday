extends Area2D

@export var glow: Sprite2D
@export var animation_player: AnimationPlayer

var chosen_player: Tank = null
var value = 50
@export var color = Color(0, 255, 0)

func _ready():
	glow.modulate = color

func _process(_delta):
	if not chosen_player:
		return
		
	var distance = position - chosen_player.position
	
	if distance.length() <= 200:
		position -= distance.normalized() * (400.0 / distance.length())
		
		if distance.length() <= 20:
			var stats = chosen_player.behaviour(Enums.COMPONENTS.STATS)
			stats.set_points(stats.points + value)
			queue_free()

func _on_area_2d_body_entered(body):
	if not body is Tank:
		return
		
	if not chosen_player:
		chosen_player = body
		return

	var distance_chosen = global_position.distance_to(chosen_player.global_position)
	var distance_body = global_position.distance_to(body.global_position)

	if body.behaviour(Enums.COMPONENTS.STATS) and distance_body < distance_chosen:
		chosen_player = body
