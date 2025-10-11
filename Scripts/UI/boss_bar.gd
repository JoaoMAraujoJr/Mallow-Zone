extends Control
class_name BossBar

@onready var _progressionBar := $TextureProgressBar
@onready var _bossTitle := $Label
@onready var _animPlayer := $AnimationPlayer
var isVisible := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	isVisible = false
	visible = false
	BossManager.Bossbar = self
	pass # Replace with function body.

func updateBossName(BossName : String):
	_bossTitle.text = BossName

func updateBossBar(CurrentHP:int , MaxHp:int):
	_progressionBar.max_value = MaxHp
	var tween := create_tween()
	tween.tween_property(
		_progressionBar, "value", CurrentHP, 0.2
	)

func changeVisibility( ShouldBeVisible : bool):
		if ShouldBeVisible == true:
			_animPlayer.play("BossBarSpawn")
			visible=ShouldBeVisible
			isVisible = ShouldBeVisible
		if ShouldBeVisible == false:
			_progressionBar.value = 0
			_animPlayer.play_backwards("BossBarSpawn")
			await _animPlayer.animation_finished
			visible=ShouldBeVisible
			isVisible = ShouldBeVisible
