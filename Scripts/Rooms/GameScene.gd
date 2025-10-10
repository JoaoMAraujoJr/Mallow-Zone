class_name Stage
extends Node2D

# ===== NODES =====
@onready var StageArea: Area2D = $StageArea
@onready var EnemySpawnArea: Area2D = $EnemySpawnArea
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
@onready var biome: String = "chess"
@onready var ThisBiome : Biome

# ===== BIOMES =====
@export var ChessBiome: PackedScene
@export var GrassBiome: PackedScene
@export var AsphaltBiome:PackedScene
var StageScene: PackedScene = preload("res://Scenes/Gamescene.tscn")

#==== SPAWNABLES =====
@export var MedikitScene: PackedScene = preload("res://Scenes/objects/medikit.tscn")
@export var AmmoScene: PackedScene = preload("res://Scenes/objects/ammo.tscn")
@export var EnemyScene: PackedScene = preload("res://Scenes/enemies/enemy.tscn")
@export var BHScene: PackedScene = preload("res://Scenes/enemies/blackhole_enemy.tscn")
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
	
	if Global.currentbiome==null:
		biome="chess"
	else:
		biome = Global.currentbiome
		
	match biome:
		"chess":
			var plataform :Biome= ChessBiome.instantiate().init(isthisroot)
			_setbiome(plataform)
		"grasslands":
			var plataform:Biome = GrassBiome.instantiate().init(isthisroot)
			_setbiome(plataform)
		"asphalt":
			var plataform = AsphaltBiome.instantiate().init(isthisroot)
			_setbiome(plataform)
		
# ===== TRIGGERS =====
func _on_trigger_left_entered(body):
	if !isLeftTriggered and body.is_in_group("PlayerArea"):
		isLeftTriggered = true
		TriggerLeft.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageLeftPosition.position, TriggerLeft)
func _on_trigger_right_entered(body):
	if !isRightTriggered and body.is_in_group("PlayerArea"):
		isRightTriggered = true
		TriggerRight.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageRightPosition.position, TriggerRight)
func _on_trigger_up_entered(body):
	if !isUpTriggered and body.is_in_group("PlayerArea"):
		isUpTriggered = true
		TriggerUp.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageUpPosition.position, TriggerUp)
func _on_trigger_down_entered(body):
	if !isDownTriggered and body.is_in_group("PlayerArea"):
		isDownTriggered = true
		TriggerDown.set_deferred("monitoring",false)
		call_deferred("_spawn_stage_at_deferred", StageDownPosition.position, TriggerDown)

# ===== SPAWN STAGE =====
func _spawn_stage_at_deferred(markerposition: Vector2, trigger: Area2D) -> void:
	if trigger.is_queued_for_deletion():
		return
	trigger.queue_free()
	print("Tentando spawn em: ", markerposition, " trigger: ", trigger.name)

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
				print("Stage já existe adjacente à ", trigger.name)
				trigger.queue_free()
				return

	# Instantiate new stage
	var new_stage : Stage = StageScene.instantiate()
	new_stage.position = markerposition
	add_child(new_stage)
	trigger.queue_free()
	print("Stage spawnada em: ", new_stage.global_position)
	

func _setbiome(plataform : Biome):
		plataform. global_position = global_position

		get_tree().current_scene.add_child.call_deferred(plataform)
		StageArea = plataform.get_stage_area()
		EnemySpawnArea = plataform.get_enemy_area()
		ThisBiome = plataform
		

func  _getbiome() -> Biome:
	return ThisBiome
	
