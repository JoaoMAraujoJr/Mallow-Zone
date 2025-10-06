extends Node2D

@onready var stage_area = $StageArea
@onready var enemy_spawn_area = $EnemySpawnArea
@onready var _isroot = false

func _ready() -> void:
	pass

func get_stage_area() -> Area2D:
	return stage_area

func get_enemy_area() -> Area2D:
	return enemy_spawn_area
