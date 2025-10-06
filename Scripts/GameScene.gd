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

# ===== BIOMES =====
@export var ChessBiome: PackedScene
var StageScene: PackedScene = preload("res://Scenes/Gamescene.tscn")
#==== SPAWNABLES =====
@export var MedikitScene: PackedScene = preload("res://Scenes/medikit.tscn")
@export var AmmoScene: PackedScene = preload("res://Scenes/ammo.tscn")
@export var EnemyScene: PackedScene = preload("res://Scenes/enemy.tscn")
@export var BHScene: PackedScene = preload("res://Scenes/blackhole_enemy.tscn")
# ===== FLAGS =====
var isLeftTriggered := false
var isRightTriggered := false
var isUpTriggered := false
var isDownTriggered := false

@export var isthisroot: bool = false

# ===== RNG =====
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var biome: String = "chess"
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
			var plataform = ChessBiome.instantiate()
			plataform. global_position = global_position
			get_tree().current_scene.add_child.call_deferred(plataform)
			StageArea = plataform.get_stage_area()
			EnemySpawnArea = plataform.get_enemy_area()
			
		
		
# ===== TRIGGERS =====
func _on_trigger_left_entered(body):
	if !isLeftTriggered and body.is_in_group("PlayerArea"):
		isLeftTriggered = true
		call_deferred("_spawn_stage_at_deferred", StageLeftPosition.position, TriggerLeft)

func _on_trigger_right_entered(body):
	if !isRightTriggered and body.is_in_group("PlayerArea"):
		isRightTriggered = true
		call_deferred("_spawn_stage_at_deferred", StageRightPosition.position, TriggerRight)

func _on_trigger_up_entered(body):
	if !isUpTriggered and body.is_in_group("PlayerArea"):
		isUpTriggered = true
		call_deferred("_spawn_stage_at_deferred", StageUpPosition.position, TriggerUp)

func _on_trigger_down_entered(body):
	if !isDownTriggered and body.is_in_group("PlayerArea"):
		isDownTriggered = true
		call_deferred("_spawn_stage_at_deferred", StageDownPosition.position, TriggerDown)

# ===== HELPER =====
func _get_random_point_in_stage(stage: Node2D) -> Vector2:
	var area: Area2D = stage.get_node("StageArea")
	var shape: CollisionShape2D = area.get_node("CollisionShape2D")
	
	if shape.shape is RectangleShape2D:
		var rect_size = shape.shape.extents * 2.0
		var top_left_global = area.global_position - shape.shape.extents
		return top_left_global + Vector2(
			rng.randf() * rect_size.x,
			rng.randf() * rect_size.y
		)
	else:
		print("⚠ Only RectangleShape2D supported")
		return area.global_position

# ===== SPAWN STAGE =====
func _spawn_stage_at_deferred(position: Vector2, trigger: Area2D) -> void:
	if trigger.is_queued_for_deletion():
		return
	trigger.queue_free()
	print("Tentando spawn em: ", position, " trigger: ", trigger.name)

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
	var new_stage = StageScene.instantiate()
	new_stage.position = position
	add_child(new_stage)
	trigger.queue_free()
	print("Stage spawnada em: ", new_stage.global_position)

	# Spawn ammo inside stage
	if rng.randf() <= 0.8 and !isthisroot:
		var ammo = AmmoScene.instantiate()
		ammo.global_position = _get_random_point_in_stage(new_stage)
		get_tree().current_scene.add_child(ammo)
		print("Munição spawnada em: ", ammo.global_position)

	if rng.randf() <= 0.05 and !isthisroot:
		var medkit = MedikitScene.instantiate()
		medkit.global_position = _get_random_point_in_stage(new_stage)
		get_tree().current_scene.add_child(medkit)
		print("medkit spawnada em: ", medkit.global_position)
		
	# Spawn enemy
	if rng.randf() <= 0.5 and !isthisroot:
		var enemy = EnemyScene.instantiate()
		enemy.global_position = _get_random_point_in_stage(new_stage)
		get_tree().current_scene.add_child(enemy)
		print("Inimigo spawnado em: ", enemy.global_position)
		
	#Spawn de BH
	if rng.randf() <= 0.1 and !isthisroot:
		if (Global.player_x > 10000.0 or Global.player_x < -10000.0 or Global.player_y > 10000.0 or Global.player_y < -10000.0) :
			var BH = BHScene.instantiate()
			BH.global_position = _get_random_point_in_stage(new_stage)
			get_tree().current_scene.add_child(BH)
			print("Inimigo spawnado em: ", BH.global_position)
