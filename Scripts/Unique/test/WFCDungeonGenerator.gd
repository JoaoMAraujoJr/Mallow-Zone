extends Node2D
class_name DungeonGenerator

@export var max_rooms := 50
var room_count := 0

@export var seed_value : String = ""

@export var all_rooms : Array[room_entry]
@export var start_room :PackedScene
@export var dead_end_rooms : Array[room_entry]

var taken_positions : Array[Vector2] = []
var branch_expansion_queue : Array = []

# No topo do DungeonGenerator
@export var grid_step := Vector2(576, 576) # Ajuste no Inspector para o tamanho da sua sala


var rooms_by_position := {}


func _ready() -> void:
	if seed_value != "":
		seed(seed_value.hash())
	else:
		randomize()
	
	var first_room = start_room.instantiate()

	first_room.global_position = Vector2.ZERO

	taken_positions.append(Vector2.ZERO)
	room_count = 1

	add_child(first_room)
	rooms_by_position[Vector2.ZERO] = first_room
	branch_expansion_queue.append(first_room)
	process_generation()

func rooms_match(roomA: room_entry, roomB: room_entry, direction:int) -> bool:
	match direction:
		0: # north
			return roomA.north == roomB.south
		1: # south
			return roomA.south == roomB.north
		2: # west
			return roomA.west == roomB.east
		3: # east
			return roomA.east == roomB.west
	return false


func get_valid_rooms(from_room: room_entry, direction:int) -> Array[room_entry]:
	var valid : Array[room_entry]= []

	for room in all_rooms:
		if rooms_match(from_room, room, direction):
			valid.append(room)

	return valid

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

func generate_room(pos: Vector2, direction:int, from_room: room_entry):
	if room_count >= max_rooms:
		return
	if pos in taken_positions:
		return

	var candidates = get_valid_rooms(from_room, direction)
	var valid_rooms : Array[room_entry] = []

	for r in candidates:
		if fits_neighbors(r, pos):
			valid_rooms.append(r)
			
	var chosen = pick_weighted_room(valid_rooms)
	
	if chosen == null or chosen.room_path == null:
		print("null room or null room path selected")
		return
	var new_room = load(chosen.room_path).instantiate()
	new_room.global_position = pos
	
	new_room.room_data = chosen
	
	taken_positions.append(pos)
	room_count += 1
	
	add_child(new_room)
	rooms_by_position[pos] = new_room
	branch_expansion_queue.append(new_room)


func fits_neighbors(candidate: room_entry, pos: Vector2) -> bool:
	# Mapeamos as direções relativas e o que elas representam para a sala candidata
	# Vector2.UP (0, -1) significa que o vizinho está ACIMA da posição atual
	var neighbors_to_check = {
		Vector2.UP: "north",
		Vector2.DOWN: "south",
		Vector2.LEFT: "west",
		Vector2.RIGHT: "east"
	}

	for offset in neighbors_to_check:
		var check_pos = pos + (offset * grid_step)
		
		if rooms_by_position.has(check_pos):
			var neighbor_room = rooms_by_position[check_pos]
			var neighbor_data = neighbor_room.room_data
			var side = neighbors_to_check[offset]

			# Validação Bidirecional:
			# Se olhamos para o NORTE, a porta NORTE da candidata 
			# deve bater com a porta SUL do vizinho.
			match side:
				"north":
					if candidate.north != neighbor_data.south: return false
				"south":
					if candidate.south != neighbor_data.north: return false
				"west":
					if candidate.west != neighbor_data.east: return false
				"east":
					if candidate.east != neighbor_data.west: return false
					
	return true

func fits_neighbors_strictly(candidate: room_entry, pos: Vector2) -> bool:
	var neighbors_to_check = {
		Vector2.UP: "north",
		Vector2.DOWN: "south",
		Vector2.LEFT: "west",
		Vector2.RIGHT: "east"
	}

	for offset in neighbors_to_check:
		var check_pos = pos + (offset * grid_step)
		var side = neighbors_to_check[offset]
		
		# Se TEMOS vizinho, a porta deve bater com a porta oposta dele
		if rooms_by_position.has(check_pos):
			var neighbor_data = rooms_by_position[check_pos].room_data
			match side:
				"north": if candidate.north != neighbor_data.south: return false
				"south": if candidate.south != neighbor_data.north: return false
				"west":  if candidate.west != neighbor_data.east: return false
				"east":  if candidate.east != neighbor_data.west: return false
		
		# Se NÃO TEMOS vizinho (é o vazio da borda), a candidata NÃO PODE ter porta!
		else:
			match side:
				"north": if candidate.north: return false
				"south": if candidate.south: return false
				"west":  if candidate.west: return false
				"east":  if candidate.east: return false
				
	return true

func expand_room(room):
	# Criamos uma lista com os índices das direções (0 a 3)
	var keys = room.markers.keys()
	keys.shuffle() # Aleatoriza a ordem de expansão das portas desta sala
	
	for dir in keys:
		# Verifica se a sala atual realmente tem porta nesta direção >>>
		var has_door := false
		match dir:
			0: has_door = room.room_data.north
			1: has_door = room.room_data.south
			2: has_door = room.room_data.west
			3: has_door = room.room_data.east
			
		# Se não houver porta nesta direção, ignoramos e não geramos nada ali!
		if not has_door:
			continue
			
		var marker = room.markers[dir]
		var pos = marker.global_position.snapped(grid_step)
		generate_room(pos, dir, room.room_data)

func process_generation():
	while branch_expansion_queue.size() > 0 and room_count < max_rooms:
		# Escolhe um índice aleatório da fila para expandir de qualquer ponto da dungeon
		# Isso cria "tentáculos" e ramificações em vez de um bloco sólido
		var rand_idx = randi() % branch_expansion_queue.size()
		var room = branch_expansion_queue.pop_at(rand_idx)
		
		expand_room(room)
		
	close_open_doors()

func get_dead_end(direction:int) -> room_entry:
	for room in dead_end_rooms:

		match direction:
			0: if room.south: return room
			1: if room.north: return room
			2: if room.east: return room
			3: if room.west: return room

	return null

func close_open_doors():
	# Criamos uma lista de posições que precisam de fechamento para não alterar o dicionário enquanto iteramos
	var positions_to_check = rooms_by_position.keys()
	
	for pos in positions_to_check:
		var room = rooms_by_position[pos]
		var data = room.room_data
		
		# Direções e suas propriedades correspondentes
		var checks = [
			{"offset": Vector2.UP,    "has_door": data.north, "dir_idx": 0},
			{"offset": Vector2.DOWN,  "has_door": data.south, "dir_idx": 1},
			{"offset": Vector2.LEFT,  "has_door": data.west,  "dir_idx": 2},
			{"offset": Vector2.RIGHT, "has_door": data.east,  "dir_idx": 3}
		]
		
		for check in checks:
			var target_pos = pos + (check.offset * grid_step)
			
			# Se existe uma porta apontando para o vazio, precisamos fechar
			if check.has_door and not rooms_by_position.has(target_pos):
				# Procuramos um dead_end que se encaixe não só com esta porta,
				# mas também com possíveis vizinhos laterais do buraco
				place_dead_end(target_pos)

func place_dead_end(pos: Vector2):
	if rooms_by_position.has(pos):
		return

	var valid_rooms : Array[room_entry] = []
	
	# Usamos ALL_ROOMS aqui. Se houver um buraco que conecta 3 corredores,
	# o gerador vai achar a sala de 3 portas que encaixa perfeitamente.
	for candidate in all_rooms:
		if fits_neighbors_strictly(candidate, pos):
			valid_rooms.append(candidate)
	
	# Se ainda assim não achar nada, precisamos de uma sala 100% parede (totalmente fechada)
	# ou escolher a que tem menos erros. Mas com 16 variações, SEMPRE haverá uma combinação.
	var chosen = pick_weighted_room(valid_rooms)
	
	if chosen:
		var new_room = load(chosen.room_path).instantiate()
		new_room.global_position = pos
		
		new_room.room_data = chosen
		
		add_child(new_room)
		rooms_by_position[pos] = new_room
		taken_positions.append(pos)
	else:
		print("Erro: Mesmo com todas as opções, nada encaixou em ", pos)
