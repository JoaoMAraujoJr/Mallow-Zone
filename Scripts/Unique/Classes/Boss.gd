extends RigidDamageable
class_name RigidBoss

signal change_on_boss_status(BossName:String  ,currentHP:int ,IsOnBoss:bool, IsBossDefeated: bool)


@export var boss_name : String

func _ready() -> void:
	super()
	if BossManager.BossList.has(boss_name):
		max_health = BossManager.BossList[boss_name]["maxHP"]
		health = BossManager.BossList[boss_name]["maxHP"]
	self.change_on_boss_status.connect(BossManager.change_on_boss_status_received)
	emit_signal("change_on_boss_status",boss_name,health,true,false)

func addToHealth(i:int) -> void:
	super(i)
	if health <= 0:
		emit_signal("change_on_boss_status",boss_name,0,false,true)
	else:
		emit_signal("change_on_boss_status",boss_name,health,true,false)
