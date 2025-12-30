extends Node2D
class_name Biome

@onready var stage_area = $StageArea
@onready var areashape = $EnemySpawnArea/CollisionShape2D
@onready var enemy_spawn_area = $EnemySpawnArea
var _isroot :bool = false
@export var _topTextureVariants : Array[Texture2D]
@onready var _top = $top

#==== SPAWNABLES =====
enum SpawnAreas{
	STAGE,
	ENEMY,
	OBJECT
}

@export_range(0.0,1.0,0.01) var enemySpawnRate : float = 0.5
@export_range(0.0,1.0,0.01) var dropSpawnRate : float = 0.5

@export var enemiesList : Array[SpawnEntry]
@export var itemDropsList : Array[SpawnEntry]
@export var ObjectsList : Array[SpawnEntry]
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

func _get_random_point_in_area(area:SpawnAreas) -> Vector2:
	var thisAreaCollisionShape:CollisionShape2D
	match area:
		SpawnAreas.STAGE:
			thisAreaCollisionShape = $StageArea/CollisionShape2D
		SpawnAreas.ENEMY:
			thisAreaCollisionShape = $EnemySpawnArea/CollisionShape2D
		SpawnAreas.OBJECT:
			thisAreaCollisionShape = $ObjectSpawnArea/CollisionShape2D
	
	if thisAreaCollisionShape.shape is RectangleShape2D:
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
	if (enemiesList != null ) and (enemiesList.size() > 0):
		rng.randomize() 
		var rand_chance:float = randf()
		for enemy in enemiesList:
			if rand_chance <= enemy.SpawnRate:
				var newEnemy = enemy.SpawnableScene.instantiate()
				if enemy.isRandomPosition:
					newEnemy.global_position = _get_random_point_in_area(SpawnAreas.ENEMY)
				else:
					newEnemy.global_position = global_position
				get_tree().current_scene.add_child(newEnemy)
				print("Inimigo spawnado em: ", newEnemy.global_position)
	
	if (itemDropsList != null ) and (itemDropsList.size() > 0):
		rng.randomize() 
		var rand_chance:float = randf()
		for item in itemDropsList:
			if rand_chance <= item.SpawnRate:
				var newitem = item.SpawnableScene.instantiate()
				if item.isRandomPosition:
					newitem.global_position = _get_random_point_in_area(SpawnAreas.STAGE)
				else:
					newitem.global_position = global_position
				get_tree().current_scene.add_child(newitem)
				print("Item dropado em: ", newitem.global_position)

	if (ObjectsList != null ) and (ObjectsList.size() > 0):
		rng.randomize() 
		if !_isroot: 
			var random_index = randi() % ObjectsList.size()
			var randomObjectScene = ObjectsList[random_index]
			if randomObjectScene == null or randomObjectScene.SpawnableScene == null:
				pass
			else:
				var newObject = randomObjectScene.SpawnableScene.instantiate()
				if ObjectsList[random_index].isRandomPosition:
					newObject.global_position = _get_random_point_in_area(SpawnAreas.OBJECT)
				else:
					newObject.global_position = global_position
				get_tree().current_scene.add_child.call_deferred(newObject)


#	if !BossManager._isOnBoss:
#		EntityspawnerAtMilestone(BossManager.NextMilestone)

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
