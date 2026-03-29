extends CanvasLayer

@onready var progressBar = $text/TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if GameManager.cur_hp <= 0:
		visible = true
	if Input.is_action_pressed("RestartButton") and GameManager.cur_hp <= 0:
		$HoldAnimPlayer.play("hold")
		if progressBar.value == progressBar.max_value:
			GameManager.kills= 0
			GameManager.enemySpeed= 50.0
			GameManager.ammo= GameManager.ammoMax
			GameManager.currentEquipedWeaponType = "none"
			GameManager.thisPlayer = null
			GameManager.cur_hp = GameManager.max_hp
			GameManager.currentSpawnedChunks = {}
			LevelManager.cur_place = preload("res://Scripts/Resources/Biomes/GrassLands.tres")
			GameManager.can_shoot = true
			BossManager._isOnBoss = false
			BossManager.currentBossName = ""
			get_tree().change_scene_to_file("res://Scenes/Level.tscn")
	else:
		$IddleAnimPlayer.play("popping")
		progressBar.value -= 1
	pass


func _on_timer_timeout() -> void:
	if Input.is_action_pressed("RestartButton"):
		progressBar.value +=1
	pass # Replace with function body.
