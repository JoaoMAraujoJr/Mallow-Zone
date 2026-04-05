extends Node2D

@export var room_data : room_entry

@onready var markers = {
	0 : $N,
	1 : $S,
	2 : $W,
	3 : $E
}
