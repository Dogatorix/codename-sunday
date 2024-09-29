extends CanvasLayer

var scope := {
	"name": "Tree",
	"nodes": []
}

var target_node
var selected_nodes := []
var tracked_properties := {}

@export var button_scene: PackedScene

func _process(_delta):
	if Input.is_action_just_pressed("toggle_console"):
		toggle_console()
	
	if Input.is_action_just_pressed("console_last"):
		%Command.text = %LastExecuted.text.substr(15)
		%Command.caret_column = %Command.text.length()
		
	process_track()

func toggle_console():
	Global.no_console = !Global.no_console
	%Console.visible = !%Console.visible
	%Command.editable = !%Command.editable
	%TrackText.visible = !%TrackText.visible
	%Command.grab_focus()
	
func _ready():
	Global.no_console = true
	
	scope.name = get_tree().current_scene
	update_scope()
	
func _on_scope_press(node):
	if not Input.is_action_pressed("console_nav"):
		scope.name = node
		update_scope()
	elif Input.is_action_pressed("console_multiselect"):
		if selected_nodes.has(node):
			selected_nodes.erase(node)
		else:
			selected_nodes.push_front(node)
		
		append("Selection is now %s nodes" % [selected_nodes.size()])
		for selected_node in selected_nodes:
			append(selected_node, false)
		line_break()
	else:
		target_node = node
		
		append("Target node: %s" % [target_node])
		line_break()
		
func _on_scope_back_pressed():
	var scope_parent = scope.name.get_parent()
	
	if scope_parent:
		scope.name = scope_parent
		update_scope()

func update_scope():
	for node in %Scope.get_children():
		node.disconnect("pressed", Callable(self, "_on_scope_press"))
		node.disconnect("mouse_entered", Callable(self, "_on_scope_button_entered"))
		node.disconnect("mouse_exited", Callable(self, "_on_scope_button_exited"))
		node.queue_free()

	scope.nodes = scope.name.get_children()
	%ScopeName.text = scope.name.get_path()
	
	for node in scope.nodes:
		create_scope_button(node)

func create_scope_button(node):
	var button_instance = button_scene.instantiate()
	button_instance.text = node.name
	button_instance.get_node("Subtext").text = str(node.get_child_count())
	%Scope.add_child(button_instance)
	
	button_instance.connect("pressed", Callable(self, "_on_scope_press").bind(node))
	button_instance.connect("mouse_entered", Callable(self, "_on_scope_button_entered").bind(node))
	button_instance.connect("mouse_exited", Callable(self, "_on_scope_button_exited").bind(node))
	
func handle_commands(command: String, args: Array):
	if command == "get":
		get_target(target_node, args)
		return
		
	if command == "set":
		set_target(target_node, args)
		return
			
	if command == "call":
		call_target(target_node, args)
		return
		
	if command == "track" or command == "tr":
		track(target_node, args)
		return
		
	if command == "getall" or command == "geta":
		for selected in selected_nodes:
			get_target(selected, args, true)
		line_break()
		return
		
	if command == "setall" or command == "seta":
		for selected in selected_nodes:
			set_target(selected, args)
		line_break()
		return
		
	if command == "callall" or command == "calla":
		for selected in selected_nodes:
			call_target(selected, args, true)
		return	
		
	if command == "clear":
		%Output.text = ""
		return
		
	if command == "refresh":
		_ready()
		%Output.text = ""
		return
			
	if command == "help":
		append('Scope nagivator - Right click to select target, Left click to traverse, Middle click to multi-select \n')
		
		append("List of all commands: \n", false)
		
		append('get {property} / "all"', false)
		append('set {property} {value}', false)
		append('call {method} {...args} / "all" \n', false)
		
		append('getall {property}', false)
		append('setall {property} {value}', false)
		append('callall {method} {...args} \n', false)
		
		append('clear', false)
		return
	
	append("Unknown command: %s \n" % [command])

func _on_line_edit_text_submitted(text: String):
	if Global.no_console or not text:
		return
	
	%Command.text = ""
	%LastExecuted.text = "Last executed: " + text
	
	var elements = text.split(" ", false)
	var command = elements[0]
	handle_commands(command, elements.slice(1))

### COMMANDS

# TARGET MANIPULATION

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

### ABSRACT METHODS

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
	@warning_ignore("integer_division")
	var minutes = ms / 60000
	@warning_ignore("integer_division")
	var seconds = (ms % 60000) / 1000
	var milliseconds = ms % 1000

	var minutes_str = str(minutes).pad_zeros(2)
	var seconds_str = str(seconds).pad_zeros(2)
	var milliseconds_str = str(milliseconds).pad_zeros(3)

	return "%s:%s:%s" % [minutes_str, seconds_str, milliseconds_str]

func line_break():
	append("", false)
	
func track(target, args):
	if not target:
		append("Select a target node first")
		return
	
	var property = tracked_properties.get(target)
	
	if not property:
		tracked_properties[target] = {}
		
	tracked_properties[target][args[0]] = null	
	
func process_track():
	%TrackText.text = ""
	
	for node in tracked_properties:
		%TrackText.text += "%s\n" % [node]
		for property in tracked_properties[node].keys():
			var value = node[property]
			%TrackText.text += "   %s : %s\n" % [property, value]

### OTHER

var button_modulate_original: Color
func _on_scope_button_entered(node):
	
	if node.get("modulate"):
		button_modulate_original = node.modulate
		node.modulate = Color(1,0,0) 

func _on_scope_button_exited(node):
	if node.get("modulate"):
		node.modulate = button_modulate_original
