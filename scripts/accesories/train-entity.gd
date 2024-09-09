extends StaticBody2D

@export var sprite_mask: Control
@export var hitbox: CollisionShape2D
@export var animation_player: AnimationPlayer
@export var train_sprite: Sprite2D

var mask_height := 1000.0
var continue_loop := false

signal loop_end()

func _ready():
	sprite_mask.size.y = mask_height
	hitbox.shape.size.y = mask_height

func drive_loop_start():
	animation_player.play("emerge")
	continue_loop = true
	$Duration.start()

func on_drive_loop_update():
	if not continue_loop:
		loop_end.emit()
		animation_player.stop()
		animation_player.play("leave")
		return

	animation_player.play("drive_loop")

func _on_duration_timeout():
	continue_loop = false

func switch_hinges():
	for hinge in train_sprite.get_children(): 
		if randi_range(0,10) < 6:
			hinge.visible = true
		else:
			hinge.visible = false
