extends Node2D

@export var is_root : bool = false
@export var north_rooms : Array[room_entry]
@export var west_rooms : Array[room_entry]
@export var east_rooms : Array[room_entry]
@export var south_rooms: Array[room_entry]



@onready var self_coords : Vector2i = get_global_position()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print( north_rooms.size())
	print(south_rooms.size())
	print(west_rooms.size())
	print(east_rooms.size())
	if is_root == true:
		if get_tree().current_scene.is_in_group("Root"):
			var tree_root = get_tree().current_scene
			tree_root.taken_chunks.append(self_coords)
	print(get_tree().current_scene.name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func pick_weighted_room(rooms: Array[room_entry]) -> room_entry:
	if rooms.is_empty():
		return null
	
	var total_weight := 0.0
	for r in rooms:
		total_weight += r.weight
	
	if total_weight == 0:
		return rooms.pick_random()
	
	var rand := randf() * total_weight
	var cumulative := 0.0
	
	for r in rooms:
		cumulative += r.weight
		if rand <= cumulative:
			return r
	
	return rooms.pick_random()


func _upon_chunk_loader_trigger_collision(area: Area2D, _self:Area2D) -> void:
	if area.is_in_group("ChunkLoader"):
		if get_tree().current_scene.is_in_group("Root"):
			var tree_root :ProceduralPlaceRoot= get_tree().current_scene
			tree_root.taken_chunks.append(self_coords)
			var markers_list = [$N, $S, $W, $E]
			var room_list = [north_rooms,south_rooms,west_rooms,east_rooms]
			
			var chunk = markers_list[_self.direction].global_position
			
			if chunk not in tree_root.taken_chunks:
				tree_root.taken_chunks.append(chunk)
				print( room_list.size())
				var new_chunk_scene = pick_weighted_room(room_list[_self.direction])
				if new_chunk_scene != null:
					var new_chunk = load(new_chunk_scene.room_path).instantiate()
					new_chunk.global_position = chunk
					get_tree().current_scene.call_deferred("add_child", new_chunk)
				else:
					print("room could not be found or was null")
			else:
				print(str(chunk), " is taken")
				_self.call_deferred("queue_free")
				return

		print("triggered on "+ str(_self.direction) +" dir")
		
	pass # Replace with function body.
