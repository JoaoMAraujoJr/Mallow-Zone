extends Node2D
class_name Biome

@onready var stage_area = $StageArea
@onready var areashape = $EnemySpawnArea/CollisionShape2D
@onready var enemy_spawn_area = $EnemySpawnArea
var _isroot :bool = false
@export var _canSpawnMedkit = true
@export var _canSpawnAmmo = true
@export var _canSpawnEnemies = true
@export var _topTextureVariants : Array[Texture2D]
@onready var _top = $top

#==== SPAWNABLES =====
@export var MedikitScene: PackedScene = preload("res://Scenes/objects/medikit.tscn")
@export var AmmoScene: PackedScene = preload("res://Scenes/objects/ammo.tscn")
@export var EnemyScene: PackedScene = preload("res://Scenes/enemies/enemy.tscn")
@export var BHScene: PackedScene = preload("res://Scenes/enemies/blackhole_enemy.tscn")

# ===== RNG =====
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func init(isrootboolean :bool) -> Biome:
	self._isroot = isrootboolean
	return self


func _ready() -> void:
	if !_isroot or _isroot == null:
		_spawn_entities_at_Stage()
	if _topTextureVariants != null and _topTextureVariants.size() > 0:
		var randomTexture :Texture2D = _topTextureVariants[randi() % _topTextureVariants.size()]
		if randomTexture != null:
			_top.texture = randomTexture
	pass

func get_stage_area() -> Area2D:
	return stage_area

func get_enemy_area() -> Area2D:
	return enemy_spawn_area

func _get_random_point_in_area() -> Vector2:
	if areashape.shape is RectangleShape2D:
		var rect_size = areashape.shape.extents * 2.0
		var top_left_global = areashape.global_position - areashape.shape.extents
		return top_left_global + Vector2(
			rng.randf() * rect_size.x,
			rng.randf() * rect_size.y
		)
	else:
		print("⚠ Only RectangleShape2D supported")
		return areashape.global_position

func _spawn_entities_at_Stage():
	if rng.randf() <= 0.8 and _canSpawnAmmo:
		var ammo = AmmoScene.instantiate()
		ammo.global_position =  _get_random_point_in_area()
		get_tree().current_scene.add_child(ammo)
		print("Munição spawnada em: ", ammo.global_position)

	if rng.randf() <= 0.05 and _canSpawnMedkit:
		var medkit = MedikitScene.instantiate()
		medkit.global_position =  _get_random_point_in_area()
		get_tree().current_scene.add_child(medkit)
		print("medkit spawnada em: ", medkit.global_position)
		
	# Spawn enemy
	if rng.randf() <= 0.5 and _canSpawnEnemies :
		var enemy = EnemyScene.instantiate()
		enemy.global_position =  _get_random_point_in_area()
		get_tree().current_scene.add_child(enemy)
		print("Inimigo spawnado em: ", enemy.global_position)
		
	#Spawn de BH
	if rng.randf() <= 0.1 :
		if (BiomeManager.currentBiome == "chess") :
			var BH = BHScene.instantiate()
			BH.global_position =  _get_random_point_in_area()
			get_tree().current_scene.add_child(BH)
			print("Inimigo spawnado em: ", BH.global_position)
	if !BossManager._isOnBoss:
		EntityspawnerAtMilestone(BossManager.NextMilestone)

func EntityspawnerAtMilestone(milestoneCoords : float ):
	var Entity : PackedScene
	for Boss in BossManager.BossList:
		if !BossManager.BossList[Boss]["isDefeated"]:
			Entity = BossManager.BossList[Boss]["BossScene"]
			break
	if Entity != null:
		if (GameManager.player_x > milestoneCoords or GameManager.player_x < -milestoneCoords or GameManager.player_y > milestoneCoords or GameManager.player_y < -milestoneCoords ):
			var newEntity = Entity.instantiate()
			newEntity.global_position = global_position
			get_tree().current_scene.add_child(newEntity)
		else:return
	else :
		print ("não ta dando")
