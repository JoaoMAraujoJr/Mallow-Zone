extends Resource
class_name SavedSettings


@export_category("Video")
@export var res :String = "1368x768"
@export var fullscreen :bool = true
@export var psx_effects :bool = true
@export var show_fps : bool = false

@export_category("Sound")
@export_range(0, 100, 1) var master_vol :float= 50.0
@export_range(0, 100, 1) var music_vol :float= 50.0
@export_range(0, 100, 1) var ambience_vol :float= 50.0
@export_range(0, 100, 1) var sfx_vol :float= 50.0
