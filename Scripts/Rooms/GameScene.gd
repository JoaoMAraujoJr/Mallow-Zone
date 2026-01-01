class_name Stage
extends Node2D

var chunk_key : Vector2i
# Spawn pivots for new stages
@onready var StageLeftPosition: Marker2D = $Positions/StageLeftPosition
@onready var StageRightPosition: Marker2D = $Positions/StageRightPosition
@onready var StageUpPosition: Marker2D = $Positions/StageUpPosition
@onready var StageDownPosition: Marker2D = $Positions/StageDownPosition

# Triggers
@onready var TriggerLeft: Area2D = $Triggers/Trigger_Left
@onready var TriggerRight: Area2D = $Triggers/Trigger_Right
@onready var TriggerUp: Area2D = $Triggers/Trigger_Up
@onready var TriggerDown: Area2D = $Triggers/Trigger_Down

# ===== BIOME =====
@onready var ThisBiome : Biome
var StageScene: PackedScene = preload("res://Scenes/Unique/Gamescene.tscn")

# ===== FLAGS =====
var isLeftTriggered := false
var isRightTriggered := false
var isUpTriggered := false
var isDownTriggered := false

@export var isthisroot: bool = false

# ===== RNG =====
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()


# ===== READY =====
func _ready() -> void:
	rng.randomize()
	TriggerLeft.connect("area_entered", Callable(self, "_on_trigger_left_entered"))
	TriggerRight.connect("area_entered", Callable(self, "_on_trigger_right_entered"))
	TriggerUp.connect("area_entered", Callable(self, "_on_trigger_up_entered"))
	TriggerDown.connect("area_entered", Callable(self, "_on_trigger_down_entered"))
	
	if BiomeManager.currentBiome==null:
		BiomeManager.currentBiome="Chess"
	else:
		var plataform :Biome = BiomeManager.BiomeList[BiomeManager.currentBiome]["BiomeScene"].instantiate().init(isthisroot)
		_setbiome(plataform)
		
func _on_trigger_left_entered(body):
	if !isLeftTriggered and body.is_in_group("ChunkLoader"):
		isLeftTriggered = true
		TriggerLeft.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageLeftPosition.position, TriggerLeft)
func _on_trigger_right_entered(body):
	if !isRightTriggered and body.is_in_group("ChunkLoader"):
		isRightTriggered = true
		TriggerRight.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageRightPosition.position, TriggerRight)
func _on_trigger_up_entered(body):
	if !isUpTriggered and body.is_in_group("ChunkLoader"):
		isUpTriggered = true
		TriggerUp.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageUpPosition.position, TriggerUp)
func _on_trigger_down_entered(body):
	if !isDownTriggered and body.is_in_group("ChunkLoader"):
		isDownTriggered = true
		TriggerDown.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageDownPosition.position, TriggerDown)

# ===== SPAWN STAGE =====
func _spawn_stage_at_deferred(markerposition: Vector2, trigger: Area2D) -> void:
	var key := Vector2i(to_global(markerposition))
	if GameManager.currentSpawnedChunks.has(key):
		return
	GameManager.currentSpawnedChunks[key]=true
	if trigger.is_queued_for_deletion():
		return

	# Instantiate new stage
	var new_stage : Stage = StageScene.instantiate()
	new_stage.global_position = markerposition
	new_stage.chunk_key = key
	add_child.call_deferred(new_stage)
	trigger.queue_free()
	#print("Stage spawnada em: ", new_stage.global_position)
	

func _setbiome(plataform : Biome):
		plataform.global_position = global_position
		get_tree().current_scene.add_child.call_deferred(plataform)
		ThisBiome = plataform
		

func  _getbiome() -> Biome:
	return ThisBiome
	
