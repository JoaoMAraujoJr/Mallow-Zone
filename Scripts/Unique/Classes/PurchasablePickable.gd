extends Pickable
class_name  PurchasablePickable

signal pickable_purchased

@export var price :int= 1
@export var price_label:Label
@export var normalPickable:PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	price_label.text = str(price) + ".00"
	itemSprite.modulate.darkened(100.0)
	pass # Replace with function body.


func UponPickup(player:Player):
	if (GameManager.gold_wallet < price):
		return
	if (GameManager.gold_wallet - price) >=0: 
		match Pickabletype:
			Types.WEAPON:
				if PickableName in ItemData.weapons.keys():
					
					GameManager.gold_wallet -= price
					pickable_purchased.emit()
					var playerOldWeapon = player._switchGun(PickableName)
					if playerOldWeapon == "none" or playerOldWeapon == null:
						queue_free()
					elif playerOldWeapon in ItemData.weapons.keys():
						var newDroppedWeapon :Pickable = normalPickable.instantiate()
						newDroppedWeapon.Pickabletype = newDroppedWeapon.Types.WEAPON
						newDroppedWeapon.PickableName = playerOldWeapon
						newDroppedWeapon.global_position = global_position
						get_tree().current_scene.add_child(newDroppedWeapon)
						queue_free()
					pass
				
			Types.CONSUMABLE:
				if PickableName in ItemData.consumables.keys():
					GameManager.gold_wallet -= price
					pass
	pass
