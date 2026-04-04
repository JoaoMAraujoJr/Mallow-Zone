extends Resource
class_name room_entry

@export_file("*.tscn") var room_path : String
@export_range(1,1000) var weight : int = 10
