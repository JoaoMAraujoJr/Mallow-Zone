extends Resource
class_name Weather

@export var name: String

@export var colorOverlay : Color = Color(0.0, 0.0, 0.0, 0.0)

@export var worldEnviromentGradiant : GradientTexture2D 
@export var weatherParticles : Array[PackedScene]
