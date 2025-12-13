extends Node2D

@onready var burning = preload("res://Scripts/Resources/Effects/burning.tres")





func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is CharacterDamageable or area.get_parent() is RigidDamageable:
		area.get_parent().addEffectToSelf(burning)
		print("player detected")
func killOil():
	queue_free()


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is CharacterDamageable or body is RigidDamageable:
		body.addEffectToSelf(burning)
		print("player detected")
	pass # Replace with function body.
