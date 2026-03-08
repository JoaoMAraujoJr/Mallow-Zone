extends Control


@export var slot_item :InventoryItem
@onready var item_sprite:Sprite2D = $item_sprite
@onready var item_shadow:Sprite2D = $item_sprite/shadow

func _ready() -> void:
	if slot_item:
		item_sprite.texture = slot_item.display_spr
	else:
		item_sprite.texture = null
	

func _get_drag_data(_at_position: Vector2):
	if slot_item == null:
		return null

	var preview = duplicate()

	var c = Control.new()
	c.add_child(preview)

	set_drag_preview(c)

	return slot_item.display_spr
