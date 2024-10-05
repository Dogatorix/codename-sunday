extends Sprite2D

@export var start_size := 0.1
@export var grow_speed := 5
@export var fade_speed := 1
@export var external := false
@export var autostart := false

var time := 0

func _ready():
	visible = false
	scale = Vector2(start_size, start_size)

func start():
	if external:
		var clone = self.duplicate()
		clone.start()
		Global.make_external(self, clone)
		return
	visible = true
	autostart = true
	
func _process(delta):
	if not autostart:
		return
	
	scale += Vector2(grow_speed, grow_speed) * delta
	modulate.a -= delta * fade_speed
	
	if modulate.a <= 0:
		queue_free()
