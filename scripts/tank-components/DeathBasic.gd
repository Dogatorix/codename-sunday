extends TankComponent
class_name DeathBasic

const component_name = "death"

@export var stats: StatsBasic

func _ready():
	if not tank:
		push_error(str(self) + "Neccesary nodes missing!")
		queue_free()
		return
		
