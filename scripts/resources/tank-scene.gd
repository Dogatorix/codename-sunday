extends Resource
class_name TankScene

enum TANKS {
	BASIC,
	CRUSH,
	ASSAULT,
	DESTROY,
}

@export var type: TANKS
@export var scene: PackedScene
