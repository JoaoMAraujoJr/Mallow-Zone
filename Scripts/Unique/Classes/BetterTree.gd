extends Interactable
class_name ForestTree

@export var tree_spr : Sprite2D
@export var animPlayer : AnimationPlayer
@export var tree_lightOccluder : LightOccluder2D
@export var tree_audioStream : AudioStreamPlayer2D
@export var particle_pos : Marker2D


@export var fruitList : Array[PackedScene] 
@export var trunk_texture : Texture2D 

@export var tree_particle_texture:CompressedTexture2D
@export var tree_particle: PackedScene 

var TurnedOn : bool = false
var isTrimmed := false
var isBeingTrimmed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	interactionArea.area_entered.connect(area_entered_tree_area)
	usageType = UsageTypes.MULTIPLE
	interactionType = InteractionTypes.SHOT
	if animPlayer:
		if "tree_breathing" in animPlayer.get_animation_list():
			animPlayer.play("tree_breathing")
	pass # Replace with function body.


func Interact():
	super.Interact()
	spawnFruit.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if !isTrimmed:
		updateTrimState()
	pass


func getRandomPointForFruitSpawn(rect: RectangleShape2D) -> Vector2:
	var half_size = rect.size / 2.0
	
	var rand_x = randf_range(-half_size.x, half_size.x)
	var rand_y = randf_range(-half_size.y, half_size.y)
	
	var reference_pos = $fruitSpawnableArea/CollisionShape2D.global_position
	
	return reference_pos + Vector2(rand_x, rand_y)

func spawnFruit() -> void:
	if isTrimmed:
		return
	if fruitList and fruitList.size() > 0:
		var new_fruit :RigidBody2D= fruitList[randi_range(0,fruitList.size()-1)].instantiate()
		new_fruit.global_position = getRandomPointForFruitSpawn($fruitSpawnableArea/CollisionShape2D.shape)
		get_tree().current_scene.add_child(new_fruit)

func spawnTreeParticles():
	if tree_particle:
		var TreePart : DestroyedTreeParticle = tree_particle.instantiate()
		tree_lightOccluder.queue_free()
		TreePart.global_position = particle_pos.global_position
			
		if tree_particle_texture:
			TreePart.tree_texture = tree_particle_texture   # ✅ AQUI
			
		TreePart.z_index = 2
		get_tree().current_scene.add_child(TreePart)
func updateTrimState():
	if isBeingTrimmed:
		spawnTreeParticles()
		tree_audioStream.pitch_scale = randf_range(0.3, 2.0)
		tree_audioStream.play()
		isTrimmed = true
		tree_spr.texture = trunk_texture

func area_entered_tree_area(area: Area2D) -> void:
	if !canInteract:
		return
	
	if area.is_in_group("canInteract") and area.get_parent() is Bullet and currentInteractionCount < maxAmmountOfInteractions:
		var body : Node2D = area.get_parent()
		Interact()
		body.queue_free()

	elif area.is_in_group("canInteract") and area.get_parent() is Bullet:
		area.get_parent().queue_free()

	if area.is_in_group("SawArea") or area.is_in_group("Car"):
		isBeingTrimmed=true
	pass # Replace with function body.
