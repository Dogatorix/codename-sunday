extends Node2D

var line_data: Array[MenuLine] = []

func _ready():
	for index in range(5):
		var menu_line: MenuLine = MenuLine.new()
		var time_id = randf_range(0, 0.5)
		var root_position = Vector2(global_position.x + (index * 50), 0)
		
		if index == 0:
			menu_line.line_width = 10

		menu_line.root_position = root_position
		menu_line.target_position = root_position
		menu_line.time_id = time_id
		menu_line.desired_position = Vector2(root_position.x, 1300)
		line_data.push_front(menu_line)
		
	for index in range(3):
		var menu_line: MenuLine = MenuLine.new()
		var time_id = randf_range(0.5, 0.8)
		var root_position = Vector2(-100, 175 + (index * 50))
		
		if index == 0:
			menu_line.line_width = 10
		
		menu_line.root_position = root_position
		menu_line.target_position = root_position
		menu_line.time_id = time_id
		menu_line.desired_position = Vector2(2000, root_position.y)
		line_data.push_front(menu_line)

var time := 0.0
func _process(delta):
	time += delta
	
	for line in line_data:
		if line.animated:
			continue
		
		if time >= line.time_id:
			line.animated = true
			Global.tween(line, "target_position", line.desired_position, 0.5, Tween.TransitionType.TRANS_EXPO, Tween.EaseType.EASE_IN)
	
	queue_redraw()

func _draw():
	for line in line_data:
		draw_line(line.root_position, line.target_position, Color.DODGER_BLUE, line.line_width)
