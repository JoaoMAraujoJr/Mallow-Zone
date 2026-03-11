extends TextureRect
class_name  InventorySlot
#inventory slot
@export var slot_index : int
@export var slot_item : InventoryItem
@onready var item_sprite:TextureRect = $item
@onready var item_shadow:Sprite2D = $shadow
var dragging := false

func _ready() -> void:
	update_ui_display()

func update_ui_display():
	if slot_item and slot_item.texture:
		item_sprite.texture = slot_item.texture
		item_shadow.texture = slot_item.texture
	else:
		item_sprite.texture = null
		item_shadow.texture = null
	

func _get_drag_data(_at_position):
	if slot_item == null:
		return

	var preview_texture := TextureRect.new()
	preview_texture.texture = slot_item.texture
	preview_texture.size = Vector2(82, 82)


	var preview := DraggableItemPreview.new()
	preview_texture.position -= preview_texture.size/2
	preview.add_child(preview_texture)

	set_drag_preview(preview)

	item_shadow.hide()
	item_sprite.hide()
	self_modulate = Color(1.0, 1.0, 1.0, 0.0)

	print("item " +slot_item.id+ " moved")
	
	dragging = true
	var drag_data = {
		"item": slot_item,
		"source_slot":self
	}
	

	return drag_data


func _can_drop_data(_pos, data):
	return data is Dictionary and data.has("item") and data is Dictionary and data.has("source_slot") 


func _drop_data(_pos, data):
	
	var item : InventoryItem = data["item"]
	var source : TextureRect = data["source_slot"]
	print("item " +data["item"].id+ " droped")
	source.dragging = false
	source.item_sprite.show()
	source.item_shadow.show()
	var temp = slot_item
	
	slot_item = item
	item_sprite.texture = item.texture
	item_shadow.texture = item.texture
	
	if temp == null:
		source.slot_item =null
		source.item_sprite.texture = null
		source.item_shadow.texture=null
	else:
		source.slot_item=temp
		source.item_sprite.texture=temp.texture
		source.item_shadow.texture=temp.texture
