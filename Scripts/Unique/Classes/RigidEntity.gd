extends RigidDamageable
class_name RigidEntity

@export var max_speed: float = 900
@export var speed: float = 200 :
	set(value):
		speed = clamp(value, 0, max_speed)
	get():
		return speed
@onready var OG_speed : float = speed

var pushingforce: Vector2 = Vector2.ZERO #empurrando
var pullingforce: Vector2 = Vector2.ZERO #puxando


func updateExternalForces(Type:String,forceVector:Vector2) : 
	match Type:
		"push":
			pushingforce = forceVector

		"pull":
			pullingforce = forceVector


func addToSpeed(Added :float):
	var percentage = 1 + Added
	speed *= percentage 

func resetSpeed():
	if speed != OG_speed:
		speed = OG_speed
