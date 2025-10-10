extends Node2D
class_name Biome

@onready var stage_area = $StageArea
@onready var enemy_spawn_area = $EnemySpawnArea
@onready var _isroot = false
@export var _topTextureVariants : Array[Texture2D]
@onready var _top = $top

func _ready() -> void:
	if _topTextureVariants != null and _topTextureVariants.size() > 0:
		var randomTexture :Texture2D = _topTextureVariants[randi() % _topTextureVariants.size()]
		if randomTexture != null:
			_top.texture = randomTexture
	pass

func get_stage_area() -> Area2D:
	return stage_area

func get_enemy_area() -> Area2D:
	return enemy_spawn_area
