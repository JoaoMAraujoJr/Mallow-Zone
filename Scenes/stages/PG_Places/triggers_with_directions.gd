extends Area2D

signal _upon_chunk_loader_trigger_collision(area: Area2D, this :Area2D)

enum dir{NORTH,SOUTH,WEST,EAST}
@export_category("Trigger Direction:")
@export var direction :dir



func _on_area_entered(area: Area2D) -> void:
	_upon_chunk_loader_trigger_collision.emit(area,self)
	pass # Replace with function body.
