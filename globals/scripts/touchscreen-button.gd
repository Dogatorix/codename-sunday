extends TouchScreenButton

var initial_action: String

@export var disabled := false:
	set(value):
		update_state(value)
		disabled = value

func _ready():
	initial_action = action
	update_state(disabled)
	
func update_state(state: bool):
	if not state:
		action = initial_action
	else:
		action = ""
