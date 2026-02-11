extends Interactable
class_name ForestTree

@onready var tree_spr : Sprite2D
@onready var animPlayer : AnimationPlayer
@onready var tree_lightOccluder : LightOccluder2D
@onready var tree_audioStream : AudioStreamPlayer2D
@onready var particle_pos : Marker2D


@export var fruitScene : PackedScene 
@export var treeTrunkTexture : Texture2D 
@export var TreeParticles : PackedScene 


var TurnedOn : bool = false
var isTrimmed := false
var isBeingTrimmed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	interactionArea = $TreeArea2D
	interactionArea.area_entered.connect(_on_tree_area_2d_area_entered)
	usageType = UsageTypes.MULTIPLE
	interactionType = InteractionTypes.SHOT
	animPlayer.play("treemovement")
	pass # Replace with function body.


func Interact():
	super.Interact()
	spawnFruit.call_deferred()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkForTrim()
	pass


func getRandomPointForFruitSpawn(rect: RectangleShape2D) -> Vector2:
	var half_size = rect.size / 2.0
	
	var rand_x = randf_range(-half_size.x, half_size.x)
	var rand_y = randf_range(-half_size.y, half_size.y)
	
	var spawn_area_center = $fruitSpawnableArea/CollisionShape2D.global_position
	
	return spawn_area_center + Vector2(rand_x, rand_y)

func spawnFruit() -> void:
	if isTrimmed:
		return
	if fruitScene:
		var new_fruit :RigidBody2D= fruitScene.instantiate()
		new_fruit.global_position = getRandomPointForFruitSpawn($fruitSpawnableArea/CollisionShape2D.shape)
		get_tree().current_scene.add_child(new_fruit)

func spawnTreeParticles():
	if TreeParticles:
		var TreePart = TreeParticles.instantiate()
		tree_lightOccluder.queue_free()
		TreePart.global_position = particle_pos.global_position
		TreePart.z_index = 2
		get_tree().current_scene.add_child(TreePart)

func checkForTrim():
	if isBeingTrimmed and !isTrimmed:
		spawnTreeParticles()
		tree_audioStream.pitch_scale = randf_range(0.3, 2.0)
		tree_audioStream.play()
		isTrimmed = true
		tree_spr.texture = treeTrunkTexture

func _on_tree_area_2d_area_entered(area: Area2D) -> void:
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
