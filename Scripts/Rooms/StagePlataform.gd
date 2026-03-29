extends Node2D
class_name newStageBiome

@onready var stage_area = $StageArea
@onready var areashape = $EnemySpawnArea/CollisionShape2D
@onready var enemy_spawn_area = $EnemySpawnArea
var _isroot :bool = false

@onready var topSprite = $top
@onready var bottomSprite=$bottom
#==== SPAWNABLES =====
enum SpawnAreas{
	STAGE,
	ENEMY,
	OBJECT
}

@export_range(0.0,1.0,0.01) var enemySpawnRate : float = 0.5
@export_range(0.0,1.0,0.01) var dropSpawnRate : float = 0.5

var thisBiome :Place = LevelManager.cur_place
@export var levelWarpScene:PackedScene

# ===== RNG =====
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func init(isrootboolean :bool) -> newStageBiome:
	self._isroot = isrootboolean
	return self


func _ready() -> void:
	if  _isroot :
		await get_tree().process_frame
		if GameManager.weatherManager:
			if GameManager.weatherManager.currentWeather != thisBiome.weather:
				GameManager.weatherManager.updateWeather(thisBiome.weather)
	if !_isroot:
		_spawn_entities_at_Stage()
	if thisBiome.topTextureVariants != null and thisBiome.topTextureVariants.size() > 0:
		var randomTexture :Texture2D = thisBiome.topTextureVariants[randi() % thisBiome.topTextureVariants.size()]
		if randomTexture != null:
			topSprite.texture = randomTexture
	if thisBiome.bottomTexturesVariants != null and thisBiome.bottomTexturesVariants.size() > 0:
		var randomTexture :Texture2D = thisBiome.bottomTexturesVariants[randi() % thisBiome.bottomTexturesVariants.size()]
		if randomTexture != null:
			bottomSprite.texture = randomTexture

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
	if (thisBiome.locatablesList != null ) and (thisBiome.locatablesList.size() > 0):
		for locatable in thisBiome.locatablesList:
			if locatable:
				var offset :int = 200
				if (global_position.x < locatable.xCoordinate + offset) and (global_position.x > locatable.xCoordinate - offset) and (global_position.y < locatable.yCoordinate + offset) and (global_position.y > locatable.yCoordinate - offset):
					print("locatable found")
					var new_locatable :Node2D= locatable.Scene.instantiate()
					new_locatable.global_position = global_position
					get_tree().current_scene.add_child(new_locatable)
					return
				offset = 1000
				if (global_position.x < locatable.xCoordinate + offset) and (global_position.x > locatable.xCoordinate - offset) and (global_position.y < locatable.yCoordinate + offset) and (global_position.y > locatable.yCoordinate - offset):
					print("locatable spawnable is close")
					return
	
	if (thisBiome.nearbyBiomesList != null ) and (thisBiome.nearbyBiomesList.size() > 0):
		for nearbyBiome in thisBiome.nearbyBiomesList:
			if nearbyBiome:
				var offset :int = 200
				if (global_position.x < nearbyBiome.xCoordinate + offset) and (global_position.x > nearbyBiome.xCoordinate - offset) and (global_position.y < nearbyBiome.yCoordinate + offset) and (global_position.y > nearbyBiome.yCoordinate - offset):
					print("locatable found")
					var new_warper :LevelWarper= levelWarpScene.instantiate()
					new_warper.global_position = global_position
					if nearbyBiome.place_id in LevelManager.placeList:
						new_warper.warpBiome = LevelManager.placeList[nearbyBiome.place_id]
					get_tree().current_scene.add_child(new_warper)

	if (thisBiome.enemiesList != null ) and (thisBiome.enemiesList.size() > 0):
		rng.randomize() 
		var rand_chance:float = randf()
		for enemy in thisBiome.enemiesList:
			if rand_chance <= enemy.SpawnRate:
				var newEnemy = enemy.SpawnableScene.instantiate()
				if enemy.isRandomPosition:
					newEnemy.global_position = _get_random_point_in_area(SpawnAreas.ENEMY)
				else:
					newEnemy.global_position = global_position
				get_tree().current_scene.add_child(newEnemy)
				print("Inimigo spawnado em: ", newEnemy.global_position)
	
	if (thisBiome.itemDropsList != null ) and (thisBiome.itemDropsList.size() > 0):
		rng.randomize() 
		var rand_chance:float = randf()
		for item in thisBiome.itemDropsList:
			if rand_chance <= item.SpawnRate:
				var newitem = item.SpawnableScene.instantiate()
				if item.isRandomPosition:
					newitem.global_position = _get_random_point_in_area(SpawnAreas.STAGE)
				else:
					newitem.global_position = global_position
				get_tree().current_scene.add_child(newitem)
				print("Item dropado em: ", newitem.global_position)

	if (thisBiome.objectsList != null ) and (thisBiome.objectsList.size() > 0):
		rng.randomize() 
		if !_isroot: 
			var random_index = randi() % thisBiome.objectsList.size()
			var randomObjectScene = thisBiome.objectsList[random_index]
			if randomObjectScene == null or randomObjectScene.SpawnableScene == null:
				pass
			else:
				var newObject = randomObjectScene.SpawnableScene.instantiate()
				if thisBiome.objectsList[random_index].isRandomPosition:
					newObject.global_position = _get_random_point_in_area(SpawnAreas.OBJECT)
				else:
					newObject.global_position = global_position
				get_tree().current_scene.add_child.call_deferred(newObject)



func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	$top.show()
	$bottom.show()
	set_process(true)
	set_physics_process(true)
	pass # Replace with function body.


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	$top.hide()
	$bottom.hide()
	set_process(false)
	set_physics_process(false)
	pass # Replace with function body.
