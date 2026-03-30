extends Resource
class_name SaveFile

@export_category("Player Stats")
@export_group("Health")
@export var cur_hp :int =100
@export_range(0, 99999) var max_hp :int =100

@export_group("Equipment")
@export var cur_skin:PlayerSkin
@export var unlocked_skins:Array[PlayerSkin] =[]
@export var cur_weapon:String = "none"
@export var inventory :Array[InventoryItem] =[]

@export_group("Others")
@export var last_saved_time: Dictionary = {}
@export var money:int = 0

@export_category("World")
@export_group("Progress")
@export var cur_place:Place = null
@export var defeated_bosses:Array[String] =[]
