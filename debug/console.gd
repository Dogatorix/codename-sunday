extends CanvasLayer

var scope := {
	"name": "Tree",
	"nodes": []
}

var target_node
var selected_nodes := []

func _process(_delta):
	if Input.is_action_just_pressed("toggle_console"):
		Global.no_console = !Global.no_console
		
		if Global.no_console:
			%Overlay.visible = false
			%Command.editable = false
		else:
			%Overlay.visible = true
			%Command.editable = true
			%Command.grab_focus()	
	
	if Input.is_action_just_pressed("console_last"):
		%Command.text = %LastExecuted.text.substr(15)
		%Command.caret_column = %Command.text.length()

func _ready():
	Global.no_console = true
	
	%Overlay.visible = false
	%Command.editable = false
	
	
	scope.nodes = get_tree().current_scene.get_children()
	scope.name = get_tree().current_scene
	
func _on_line_edit_text_submitted(text: String):
	if Global.no_console or not text:
		return
	
	%Command.text = ""
	%LastExecuted.text = "Last executed: " + text
	
	var elements = text.split(" ", false)
	var command = elements[0]
	handle_commands(command, elements.slice(1))
	
func handle_commands(command: String, args: Array):
	match command:
		"scope":
			var operation = "all"
			if args:
				operation = args[0]
			 
			if operation != "all" and operation != "back":
				var node_index = int(operation)
					
				if node_index < 0 or node_index > (scope.nodes.size() - 1):
					append("Argument 0 out of range")
					return
					
				var chosen_node = scope.nodes[node_index]
				scope.name = chosen_node
				scope.nodes = chosen_node.get_children()
			if operation == "back":
				var chosen_node = scope.name.get_parent()
				scope.name = chosen_node
				scope.nodes = chosen_node.get_children()
				
			append("SCOPE - " + str(scope.name))
			for index in range(scope.nodes.size()):
				append(str(index) + ". " + str(scope.nodes[index]), false)
			line_break()
			
		"target":
			if not args:
				append("Please specify arguments")
				return
			
			target_node = scope.nodes[int(args[0])]
			append("Target node: " + str(target_node))
			
		"get":
			get_target(target_node, args)
		
		"set":
			set_target(target_node, args)		
			
		"call":
			call_target(target_node, args)
			
		"select":
			if not args:
				append("Please specify arguments")
				return
			
			if args[0] == "clear":
				selected_nodes = []
				append("Selection cleared")
			else:
				for string_index in args:
					var index = int(string_index)
					
					if index < 0 or index > (scope.nodes.size() - 1):
						append("Argument %s out of range" % [index], false)
						continue
						
					if selected_nodes.has(scope.nodes[index]):
						continue
						
					selected_nodes.push_front(scope.nodes[index])
					
				append("Selection is now %s total nodes" % [selected_nodes.size()])
				for selected in selected_nodes:
					append(selected, false)
				line_break()
		
		"getall":
			for selected in selected_nodes:
				get_target(selected, args, true)
			line_break()
			
		"setall":
			for selected in selected_nodes:
				set_target(selected, args)
			line_break()
		
		"callall":
			for selected in selected_nodes:
				call_target(selected, args, true)
			
		"clear":
			%Output.text = ""
		
		"refresh":
			_ready()
			%Output.text = ""
			
		"help":
			append("List of all commands: \n")
			append('scope {index} / "all" / "back" \n', false)
			
			append('target {index}', false)
			append('get {property} / "all"', false)
			append('set {property} {value}', false)
			append('call {method} {...args} / "all" \n', false)
			
			append('select {...indexes} / "clear"', false)
			append('getall {property}', false)
			append('setall {property} {value}', false)
			append('callall {method} {...args} \n', false)
			
			append('clear', false)
			append('refresh', false)

func get_target(target, args, multi := false):
	if not target:
		append("Target node missing")
		return
			
	var operation = "all"
	if args:
		operation = args[0]
	
	if operation == "all" and not multi:
		line_break()
		for property in target.get_property_list():
			var log_string = property["name"] + " : " + str(target.get(property["name"]))
			append(log_string, false)
	elif operation != "all":
		var property = target.get(args[0])
		append(str(target) + " " + args[0] + " : " + str(property))
		
func set_target(target, args):
	if not target:
		append("Target node missing")
		return
	if not args:
		append("Please include at least 2 arguments")
		return

	var value = string_to_type(args[1])
	target[args[0]] = value
	append(str(target) + " " + args[0] + " has been set to: " + str(value))
	
func call_target(target, args, multi := false):
	if not target:
		append("Select a node first")
		return
		
	var operation = "all"
	if args:
		operation = args[0]
	
	var arguments = args.slice(1)

	if operation == "all" and not multi:
		line_break()
		for method in target.get_method_list():
			append(method.name, false)
	elif operation != "all":
		if not target.has_method(operation):
			append("No such method exists")
			return
		
		var method_arguments = []
		method_arguments.resize(arguments.size())
		
		for index in range(arguments.size()):
			method_arguments[index] = string_to_type(arguments[index])
	
		var return_value = target.callv(operation, method_arguments)
		
		if return_value != null:
			append(str(target) + " " + operation + " return: " + str(return_value))

func append(text, timestamp: bool = true):
	var timestamp_color = "#A1A1A100"
	if timestamp:
		timestamp_color = "#A1A1A1"
	var timestamp_text = "[color=%s]%s[/color] " % [timestamp_color, format_time(Time.get_ticks_msec())]
	%Output.text += timestamp_text + str(text) + "\n"

func string_to_type(value):
	var expression = Expression.new()
	var error = expression.parse(value)
	if error != OK:
		append(expression.get_error_text())
		return
	var result = expression.execute()
	if not expression.has_execute_failed():
		return result

func format_time(ms: int) -> String:
	var minutes = ms / 60000
	var seconds = (ms % 60000) / 1000
	var milliseconds = ms % 1000

	var minutes_str = str(minutes).pad_zeros(2)
	var seconds_str = str(seconds).pad_zeros(2)
	var milliseconds_str = str(milliseconds).pad_zeros(3)

	return "%s:%s:%s" % [minutes_str, seconds_str, milliseconds_str]

func line_break():
	append("", false)
