extends Node2D

@export var weaponKey :String
@onready var _interactionArea : Area2D = $Area2D

func _ready() -> void:
	_reloadTexture()
	
func _process(delta: float) -> void:
	var bodies = _interactionArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("PlayerArea"):
			if Input.is_action_just_pressed("Interact"):
				var thisgun = weaponKey
				var oldcurrent = GameManager.currentEquipedWeaponType
				var oldMaxammo = GameManager.ammoMax
				_setWeaponKey(oldcurrent)
				GameManager.currentEquipedWeaponType = thisgun
				GameManager.ammoMax = ItemData.weapons[thisgun]["max_ammo"]
				if oldcurrent != thisgun and GameManager.ammoMax != oldMaxammo:
					GameManager.ammo = ItemData.weapons[thisgun]["max_ammo"]
				if body.has_method("_equipGun"):
					body._equipGun()
					_reloadTexture()


func _setWeaponKey(key : String) :
	if key == "none" or key == null:
		queue_free()
	if key in ItemData.get_weapon_names():
		weaponKey = key

func _reloadTexture():
	if weaponKey in ItemData.get_weapon_names():
		var thisgun =ItemData.weapons[weaponKey]
		$gun.texture = thisgun["texture"]
