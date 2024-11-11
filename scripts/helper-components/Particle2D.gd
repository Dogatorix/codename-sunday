extends CPUParticles2D
class_name Particle2D

@export var external := false
@export var permanent := false
@export var autostart := false

var is_summoned := false

func _ready():
	if not is_summoned:
		emitting = false
		one_shot = true
	
	if autostart:
		start.call_deferred()

func start():
	if permanent:
		emitting = true
		one_shot = false
	if is_summoned:
		return
		
	var clone: Particle2D = self.duplicate()
	clone.external = false
	clone.is_summoned = true
	clone.emitting = true
	
	if external:
		get_parent().add_sibling(clone)
	else:
		add_sibling(clone)
	clone.global_position = self.global_position
	
	if not permanent:
		Global.timeout_destroy(clone, lifetime)
		
