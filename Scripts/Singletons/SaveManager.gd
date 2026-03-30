extends Node
signal save_deleted(slot:int)
signal new_save_created(slot:int)

var current_save : SaveFile
var current_slot : int

func _ready() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("saves"):
		dir.make_dir("saves")

func create_new_save(slot:int):
	var save = SaveFile.new()
	save.cur_skin = load("res://Scripts/Resources/PlayerSkins/normal_skin.tres")
	save.cur_place = load("res://Scripts/Resources/Places/tutorial.tres")
	save.last_saved_time = Time.get_datetime_dict_from_system()
	current_save = save
	current_slot = slot
	save_game(slot)
	new_save_created.emit(slot)
	
func delete_save(slot:int):
	var path:= "user://saves/save_%d.tres" % slot
	if ResourceLoader.exists(path): 
		var error = DirAccess.remove_absolute(path)
		if error == OK:
			print("Save File deleted successfully: ", path)
			save_deleted.emit(slot)
		else:
			print("Error deleting file: ", path, " Error code: ", error)
	else:
		print("File does not exist: ", path)
		
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
