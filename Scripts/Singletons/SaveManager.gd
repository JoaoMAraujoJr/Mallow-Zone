extends Node


var current_save : SaveFile
var current_slot : int

func _ready() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func create_new_save(slot:int):
	var save = SaveFile.new()
	save.cur_skin = load("res://Scripts/Resources/PlayerSkins/retro_skin.tres")
	current_save = save
	current_slot = slot
	save_game(slot)
	
func save_game(slot:int):
	if current_save == null:
		return
	var path:= "user://saves/save_%d.tres" % slot
	ResourceSaver.save(current_save,path)

func load_game(slot:int):
	var path:= "user://saves/save_%d.tres" % slot
	if ResourceLoader.exists(path):
		current_save = ResourceLoader.load(path)
		current_slot = slot
		return true
	return false

func get_all_saves():
	var saves := []
	var dir = DirAccess.open("user://saves")
	dir.list_dir_begin()
	var file = dir.get_next()
	while file !="":
		if file.ends_with(".tres"):
			saves.append(file)
		file = dir.get_next()
	dir.list_dir_end()
	return saves
