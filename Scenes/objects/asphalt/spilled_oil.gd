extends Node2D

@onready var burning = preload("res://Scripts/Resources/Effects/burning.tres")





func killOil():
	queue_free()


func _on_damage_area_body_entered(body: Node2D) -> void:
	if body is CharacterDamageable or body is RigidDamageable:
		body.addEffectToSelf(burning)
		print("player detected")
	pass # Replace with function body.
