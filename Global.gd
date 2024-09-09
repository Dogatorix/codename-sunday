extends Node

var game_camera: GameCamera = null
var clients: Array[Tank] = []

var	no_console := true

const CORE_REQUIREMENT = {
	1: 1,
	2: 500,
	3: 2000,
	4: 8000,
	5: 25000,
}

var PRELOADS = {
	"energy-square": load("res://scenes/containers/energy-square.tscn"),
	"energy-triangle": load("res://scenes/containers/energy-triangle.tscn"),
	"energy-pentagon": load("res://scenes/containers/energy-pentagon.tscn"),
	"energy-octagon": load("res://scenes/containers/energy-octagon.tscn"),
	"ownership-component": load("res://scenes/components/OwnershipComponent.tscn"),
	"bullet": load("res://scenes/tanks/bullet.tscn"),
	"tank-trail": load("res://scenes/tanks/tank-trail.tscn")
}
