extends Node

@onready var _isOnBoss :=false
@onready var currentBossName : String = ""
@onready var currentBossHealth : int

var multiplier : int = 1

var Bossbar : BossBar 
@onready var NextMilestone : float = 5000.0

@onready var defeatedBosses : Array[String]

var BossList := {
	"Ominous Car":{
		"name": "The Ominous Car",
		"BossScene": preload("res://Scenes/enemies/car_boss.tscn"),
		"maxHP": 50 * multiplier,
		"isDefeated": false,
	},
	"Rohk":{
	"name": "Rohk The Boulder",
	"BossScene": preload("res://Scenes/enemies/car_boss.tscn"),
	"maxHP": 50 * multiplier,
	"isDefeated": false,
	}
}


func change_on_boss_status_received(BossName:String ,currentBossHP:int,IsOnBoss:bool, IsBossDefeated: bool):
	
	_isOnBoss = IsOnBoss
	
	if Bossbar == null:
		print("bossbar not Founded Yet")
		return
	
	if IsBossDefeated or !IsOnBoss:
		if BossList.has(currentBossName):
			currentBossHealth = currentBossHP
			if IsBossDefeated:
				BossList[currentBossName]["isDefeated"] = true #<===== é essa aqui BURRO
			Bossbar.updateBossBar(currentBossHealth,BossList[currentBossName]["maxHP"])
			Bossbar.changeVisibility(false)
			NextMilestone += 2000.0
			print("Boss is Defeated : " + str(BossList[currentBossName]["isDefeated"]))
	elif !IsBossDefeated and !IsOnBoss:
		currentBossName = ""
		Bossbar.changeVisibility(false)
	else:
		if BossList.has(BossName):
			currentBossName = BossName
			currentBossHealth = currentBossHP
			Bossbar.updateBossBar(currentBossHealth,BossList[currentBossName]["maxHP"])
			Bossbar.updateBossName(BossList[currentBossName]["name"])
			if (Bossbar.isVisible == false):
				Bossbar.changeVisibility(true)

	print("Boss signal recieved my friend")
