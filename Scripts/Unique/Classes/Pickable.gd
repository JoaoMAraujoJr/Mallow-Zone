extends Node2D
class_name Pickable

@export var get_by_press:bool = true
@export var get_by_approach:bool = false

@onready var can_be_picked:bool = false

@onready var BodyDetector : Area2D = $Area2D
@onready var itemSprite: Sprite2D = $DroppedItem

enum Types{
	CONSUMABLE,
	WEAPON
}

@export var Pickabletype : Types = Types.WEAPON
@export var PickableName : String


func _ready() -> void:
	reloadTexture()

func UponPickup(player:Player):
	match Pickabletype:
		Types.WEAPON:
			if PickableName in ItemData.weapons.keys():
				var newPickableName = player._switchGun(PickableName)
				if newPickableName == "none" or newPickableName == null:
					queue_free()
				elif newPickableName in ItemData.weapons.keys():
					PickableName = newPickableName
					reloadTexture()
				pass
			
		Types.CONSUMABLE:
			if PickableName in ItemData.consumables.keys():
				pass
	pass

func reloadTexture():
	match Pickabletype:
		Types.WEAPON:
			if PickableName in ItemData.weapons.keys():
				var thisWeapon = ItemData.weapons[PickableName]
				itemSprite.texture = thisWeapon["texture"]
				pass
			
		Types.CONSUMABLE:
			if PickableName in ItemData.consumables.keys():
				var thisConsumable = ItemData.consumables[PickableName]
				itemSprite.texture = thisConsumable["texture"]
				pass

func _process(delta: float) -> void:
	if !can_be_picked:
		return
	
	var bodies = BodyDetector.get_overlapping_bodies()
	var player : Player
	for body in bodies:
		if body is Player:
			player = body
			break
	if player != null:
		if get_by_approach:
			global_position= lerp(global_position,player.global_position,0.4 * delta)
			UponPickup(player)
		elif get_by_press and Input.is_action_just_pressed("Interact"):
			UponPickup(player)


func _uponBodyEnteredArea(body:Node2D):
	if !body.is_in_group("PlayerArea"):
		return
	can_be_picked = true
	if get_by_press:
		$KeyAnimation.play("topress")
	pass

func _uponBodyExitedArea(body:Node2D):
	if !body.is_in_group("PlayerArea"):
		return
	$KeyAnimation.play("RESET")

func setItemType(Type : String):
	match Type:
		"WEAPON":
			Pickabletype=Types.WEAPON
		"CONSUMABLE":
			Pickabletype=Types.CONSUMABLE
