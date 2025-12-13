extends Node2D

@onready var burning = preload("res://Scripts/Resources/Effects/burning.tres")

func killSelf():
	queue_free()


func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Damageble") and !area.is_in_group("PlayerArea"):
		if area.get_parent().has_method("addEffectToSelf"):
			area.get_parent().addEffectToSelf(burning)
	pass # Replace with function body.
