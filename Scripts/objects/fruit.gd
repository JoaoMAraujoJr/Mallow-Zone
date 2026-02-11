extends RigidBody2D

@export var RegenValue : int = 5
@onready var foodSprite : Sprite2D = $Sprite2D

func _ready() -> void:
	var new_timer :Timer= Timer.new()
	new_timer.timeout.connect(
	func():
		self.gravity_scale = 0.0 
		self.linear_velocity = Vector2.ZERO
		self.angular_velocity = 0.0
		new_timer.queue_free())
	new_timer.wait_time = randf_range(0.5,0.8)
	new_timer.autostart = true
	add_child(new_timer)
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerArea"):
		body.addToHealth(RegenValue)
		foodSprite.queue_free()
		$Area2D.queue_free()
		$EatingSound.pitch_scale = randf_range(1.2, 2)
		$EatingSound.play()
		await $EatingSound.finished
		queue_free()
	pass # Replace with function body.


func setRegenValue(value : int ):
	RegenValue = value
