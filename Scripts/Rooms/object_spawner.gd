extends Node2D

@export var SpawnableObjectList: Array[PackedScene]
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if !get_parent()._isroot: 
		if SpawnableObjectList.size() > 0:
			var random_scene = SpawnableObjectList[randi() % SpawnableObjectList.size()]
			if random_scene == null:
				return
			var instance = random_scene.instantiate()
			instance .global_position = global_position
			get_tree().current_scene.add_child.call_deferred(instance)
