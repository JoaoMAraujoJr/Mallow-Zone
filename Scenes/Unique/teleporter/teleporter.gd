@tool
@icon("res://Scenes/Unique/teleporter/teleporter.svg")
class_name Teleporter
extends Node2D

@export_category("Debug")
@export var can_tp : bool = true
@export var area: Area2D
@export var teleport_position: Marker2D

@onready var anim_player : AnimationPlayer = $CanvasLayer/AnimationPlayer
func _ready() -> void:
	if area:
		area.body_entered.connect(_upon_body_entered)

func _upon_body_entered(body:PhysicsBody2D):
	if body is CharacterDamageable:
		if can_tp and teleport_position:
			anim_player.play("warp")
			await  anim_player.animation_finished
			body.global_position = teleport_position.global_position
			anim_player.play_backwards("warp")



func _get_configuration_warnings():
	var warnings: PackedStringArray = []

	var has_area_2d := false
	var has_marker_2d := false
	var has_valid_child := false

	for child in get_children():
		if child is Marker2D:
			has_marker_2d = true
		if child is Area2D:
			has_area_2d = true
		if has_area_2d and has_marker_2d:
			has_valid_child = true
			break
		

	if not has_valid_child:
		warnings.append("Teleporter2D requires a Marker2D and a Area2D as a child.")

	return warnings
