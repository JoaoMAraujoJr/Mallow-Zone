extends Control

@export var minuteTimeInSeconds : float = 3.0
@onready var minuteTimer : Timer = $MinuteTimer
@onready var TimeDisplay: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minuteTimer.wait_time = minuteTimeInSeconds
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	printCurrentDate()
	pass

func printCurrentDate():
	@warning_ignore("integer_division")
	var hoursPassed :int = floor(DayTimeManager.currentMinutesPassed/60)
	@warning_ignore("integer_division")
	var daysPassed : int = floor((hoursPassed)/24)
	
	var currentDayHours :int = (hoursPassed%60)%24
	var currentDayMinutes : int = (DayTimeManager.currentMinutesPassed%60)
	
	TimeDisplay.text = "DAY %d, %02d:%02d" % [
		daysPassed,
		currentDayHours,
		currentDayMinutes
	]
func _upon_minute_passed() -> void:
	DayTimeManager.currentMinutesPassed +=5
