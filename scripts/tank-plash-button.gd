extends Sprite2D

signal on_click()

var disabled := true
var is_animating := false

@export var tank_id: Enums.TANKS
@export var play_animation := true
@export var tank_textures: Array[CompressedTexture2D]

@onready var time: float = randf_range(0, 5)

func _ready():
	if not play_animation:
		modulate = Color.WHITE
	
	$TankName.text = Global.TANK_NAMES[tank_id]
	$TankSprite.texture = tank_textures[tank_id]
	
	if play_animation:
		$AnimationPlayer.play('init')

func _process(delta):
	time += delta
	
	self_modulate.a = abs(sin(time * 270)) + 0.9
	$TankSprite.position.y = sin(time * 3) * 10

func _mouse_entered():
	if is_animating:
		return
		
	$AnimationPlayer.play("focus")
	$TextAnimations.play("show")
	
func _mouse_exited():
	if is_animating:
		return
		
	$TextAnimations.play("hide")
	$AnimationPlayer.play("unfocus")

func play_click_anim():
	disabled = true
	is_animating = true
	$AnimationPlayer.play("click")

func _on_button_pressed():
	if Global.Game.client and not disabled:
		on_click.emit()
		Global.Game.client.upgrade_tank(tank_id)

func on_finish():
	queue_free()
	
func _on_click_delay_timeout():
	disabled = false
