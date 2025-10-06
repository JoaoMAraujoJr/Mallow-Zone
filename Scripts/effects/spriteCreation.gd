extends Sprite2D

var time_passed := 0.0

func _ready() -> void:
	# duplica o material só pra essa instância
	material = material.duplicate()
	time_passed = 0.0
	set_process(true)
	material.set_shader_parameter("threshold", 0.0)

func _process(delta: float) -> void:
	time_passed += delta
	var t = clamp(time_passed / 1.0, 0.0, 1.0)
	material.set_shader_parameter("threshold", t)

	if t >= 1.0:
		set_process(false)
