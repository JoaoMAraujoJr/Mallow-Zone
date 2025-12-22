extends Interactable

class_name ForestTree

@onready var _treeSprite : Sprite2D = $Sprite2D
@onready var _animplayer : AnimationPlayer = $AnimationPlayer
@onready var _rootLightOcludder : LightOccluder2D = $log
@onready var _fruitSpawnerMarker:Marker2D = $Sprite2D/fruitSpawnLocation
@onready var _TreeCutterAudioStream : AudioStreamPlayer2D = $TreeCutterAudioStream
@onready var _ParticleSpawnerMarker := $ParticleSpawnerMarker


@export var fruitScene : PackedScene 
@export var rootTexture : Texture2D 
@export var TreeParticles : PackedScene 


var TurnedOn : bool = false
var isTrimmed := false
var isBeingTrimmed := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	interactionArea = $TreeArea2D
	interactionArea.area_entered.connect(_on_tree_area_2d_area_entered)
	interactionArea.area_exited.connect(_on_tree_area_2d_area_exited)
	usageType = UsageTypes.MULTIPLE
	interactionType = InteractionTypes.SHOT
	_animplayer.play("treemovement")
	pass # Replace with function body.


func Interact():
	super.Interact()
	spawnFruit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkAreasInInteractable()
	checkForTrim()

	pass


func spawnFruit() -> void:
	if isTrimmed:
		return
	if fruitScene:
		var new_fruit = fruitScene.instantiate()
		new_fruit.global_position = _fruitSpawnerMarker.global_position
		get_tree().current_scene.add_child(new_fruit)


func spawnTreeParticles():
	if TreeParticles:
		var TreePart = TreeParticles.instantiate()
		_rootLightOcludder.queue_free()
		TreePart.global_position = _ParticleSpawnerMarker.global_position
		get_tree().current_scene.add_child(TreePart)


func checkForTrim():
	if isBeingTrimmed and !isTrimmed:
		spawnTreeParticles()
		_TreeCutterAudioStream.pitch_scale = randf_range(0.3, 2.0)
		_TreeCutterAudioStream.play()
		isTrimmed = true
		_treeSprite.texture = rootTexture

func _on_tree_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("Bullet"):
		var body : Node2D = area.get_parent()
		body.visible = false
	if area.is_in_group("SawArea") or area.is_in_group("Car"):
		isBeingTrimmed=true
	pass # Replace with function body.

func _on_tree_area_2d_area_exited(area:Area2D) -> void:
	if area.get_parent().is_in_group("Bullet"):
		area.get_parent().queue_free()
	pass # Replace with function body.
