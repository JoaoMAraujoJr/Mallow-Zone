extends Resource
class_name Place

@export_category("Place Setup")

@export_group("Place Info")
@export var place_id : String
@export var display_name : String = "New Place"
@export var description : String = "???"
@export var menu_icon : Texture
@export_group("Place Level")
@export_file("*.tscn") var level_path : String
