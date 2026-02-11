extends Label3D

@export var minuteTimeInSeconds : float = 3.0
@onready var minuteTimer : Timer 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minuteTimer = Timer.new()
	minuteTimer.autostart = true
	minuteTimer.timeout.connect(_upon_minute_passed)
	minuteTimer.wait_time = minuteTimeInSeconds
	add_child(minuteTimer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	printCurrentDate()
	pass

func printCurrentDate():
	@warning_ignore("integer_division")
	var hoursPassed :int = floor(DayTimeManager.currentMinutesPassed/60)
	@warning_ignore("integer_division")
	#var daysPassed : int = floor((hoursPassed)/24)
	
	var currentDayHours :int = (hoursPassed%60)%24
	var currentDayMinutes : int = (DayTimeManager.currentMinutesPassed%60)
	
	text = "%02d:%02d" % [
		currentDayHours,
		currentDayMinutes
	]

func _upon_minute_passed() -> void:
	DayTimeManager.currentMinutesPassed +=5
