extends Resource
class_name InventoryItem
@export_category("Item Info")
@export var id :String
@export var display_spr:String

enum itemTypes{
	KEY,
	CONSUMABLE,
	OTHER
}

@export var type:itemTypes = itemTypes.KEY

@export_group("Consumable data")
@export var add_to_hp :int =0
@export var effect_list:Array[Effect]
