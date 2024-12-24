extends Sprite2D
class_name Shockwave

@export var start_size := 0.0
@export var grow_speed := 5.0
@export var fade_speed := 1.0
@export var external := false
@export var autostart := false
@export var root: Node 


func _ready():
	if not root:
		root = get_parent()
	
	visible = false
	
	if start_size:	
		scale = Vector2(start_size, start_size)
		
	if autostart:
		start()

func start():			
	if external:
		var clone = self.duplicate()
		Global.Game.make_external(self, root, clone)
		clone.start()
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
