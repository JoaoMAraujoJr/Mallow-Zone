extends Node2D

@export var SpawnableObjectList: Array[PackedScene]

# Called when the node enters the scene tree for the first time.
func _ready():
	if !get_parent()._isroot: 
		if SpawnableObjectList.size() > 0:
			var random_scene = SpawnableObjectList[randi() % SpawnableObjectList.size()]
			if random_scene == null:
				return
			var instance = random_scene.instantiate()
			add_child(instance)
