extends Area2D
class_name SpawnLocation

@onready var index = get_index() + 1

func _ready():
	visible = false
	
func show_location():
	visible = true
	$FadeIn.play("fadein")

func focus():
	$AnimationPlayer.play("focus")
	
func unfocus():
	$AnimationPlayer.play("unfocus")

func click():
	$AnimationPlayer.play("clicked")

func unclick():
	$AnimationPlayer.play("unclick")
