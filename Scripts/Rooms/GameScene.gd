class_name Stage
extends Node2D

# ===== NODES =====
@onready var StageArea: Area2D 
@onready var EnemySpawnArea: Area2D
@onready var AmmoSpawner: Marker2D = $AmmoSpawnMarker


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

# Checkers for existing stages
@onready var CheckerLeft: Area2D = $Checkers/StageCheckerLeft
@onready var CheckerRight: Area2D = $Checkers/StageCheckerRight
@onready var CheckerUp: Area2D = $Checkers/StageCheckerUp
@onready var CheckerDown: Area2D = $Checkers/StageCheckerDown

# ===== BIOME =====
@onready var ThisBiome : Biome

# ===== BIOMES =====

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
	if trigger.is_queued_for_deletion():
		return
	trigger.queue_free()
	#print("Tentando spawn em: ", markerposition, " trigger: ", trigger.name)

	# Choose the checker
	var checker: Area2D
	match trigger:
		TriggerLeft: checker = CheckerLeft
		TriggerRight: checker = CheckerRight
		TriggerUp: checker = CheckerUp
		TriggerDown: checker = CheckerDown
		_: checker = null

	# Check for existing adjacent stages
	if checker:
		for body in checker.get_overlapping_areas():
			if body.is_in_group("Stage"):
				#print("Stage já existe adjacente à ", trigger.name)
				trigger.queue_free()
				return

	# Instantiate new stage
	var new_stage : Stage = StageScene.instantiate()
	new_stage.global_position = markerposition
	add_child.call_deferred(new_stage)
	trigger.queue_free()
	#print("Stage spawnada em: ", new_stage.global_position)
	

func _setbiome(plataform : Biome):
		plataform. global_position = global_position

		get_tree().current_scene.add_child.call_deferred(plataform)
		StageArea = plataform.get_stage_area()
		EnemySpawnArea = plataform.get_enemy_area()
		ThisBiome = plataform
		

func  _getbiome() -> Biome:
	return ThisBiome
	
