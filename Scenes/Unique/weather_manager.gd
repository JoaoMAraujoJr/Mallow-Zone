extends CanvasLayer
class_name WeatherManager

@export var currentWeather : Weather
@onready var weatherOverlay : ColorRect = $WeatherOverlay

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.weatherManager = self
	pass 


func updateWeather(new_weather : Weather):
	print("weather changed to: " + new_weather.name)
	
	for child in self.get_children():
		if child.is_in_group("WeatherParticles"): # apaga particulas do clima anterior
			child.queue_free()
		
	#atualiza parametros do clima
	weatherOverlay.color = new_weather.colorOverlay
	
	for particle in new_weather.weatherParticles:
		var new_particle :Control= particle.instantiate()
		new_particle.add_to_group("WeatherParticles")
		add_child(new_particle)
	
	currentWeather = new_weather
