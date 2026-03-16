extends Node2D
class_name SkinManager

@export_category("Skin Data")
enum action_states {
	IDLE,
	WALKING,
	DEAD
}
enum expression_states {
	POKER,
	ANGRY,
	SUPRISED,
	PROUD
}
@export var is_backwards :bool =false
@export var cur_action: action_states = action_states.IDLE
@export var cur_expression: expression_states = expression_states.POKER
@export var skin :PlayerSkin

#Sprite Reference Declaration
@onready var eyebrow_l:Sprite2D = $"SkinViewport/Pivot/Body/Torso and Head/Head/Face/eyebrow_l"
@onready var eyebrow_r:Sprite2D =$"SkinViewport/Pivot/Body/Torso and Head/Head/Face/eyebrow_r"
@onready var eyes:Sprite2D = $"SkinViewport/Pivot/Body/Torso and Head/Head/Face/eyes"
@onready var mouth:Sprite2D = $"SkinViewport/Pivot/Body/Torso and Head/Head/Face/mouth"

@onready var back_hair:Sprite2D =$"SkinViewport/Pivot/Body/Torso and Head/Head/hair_spr"
@onready var head:Sprite2D=$"SkinViewport/Pivot/Body/Torso and Head/Head/head_spr"

@onready var leg_l:Sprite2D=$SkinViewport/Pivot/Body/Legs/L/leg
@onready var foot_l:Sprite2D=$SkinViewport/Pivot/Body/Legs/L/foot
@onready var leg_r:Sprite2D=$SkinViewport/Pivot/Body/Legs/R/leg
@onready var foot_r:Sprite2D=$SkinViewport/Pivot/Body/Legs/R/foot
@onready var torso:Sprite2D=$"SkinViewport/Pivot/Body/Torso and Head/Torso/torso_spr"


@export_category("Debug")
@export var use_local_skin:bool=false
@onready var character_anim_player:AnimationPlayer = $SkinViewport/Pivot/AnimationPlayer
@onready var expression_anim_player:AnimationPlayer = $"SkinViewport/Pivot/Body/Torso and Head/Head/Face/Expression_Anim_player"
@onready var skinViewport :SubViewport= $SkinViewport


func _ready() -> void:
	GameManager.skin_changed.connect(update_skin)
	if use_local_skin and skin :
		if skin.texture:
			update_skin(skin)
	else:
		skin = GameManager.cur_skin
		update_skin(skin)
	update_action()

func update_skin(new_skin:PlayerSkin):
	if new_skin == null:
		return
	eyebrow_l.texture = new_skin.texture
	eyebrow_r.texture = new_skin.texture
	eyes.texture = new_skin.texture
	mouth.texture = new_skin.texture
	back_hair.texture = new_skin.texture
	head.texture = new_skin.texture
	leg_l.texture = new_skin.texture
	foot_l.texture = new_skin.texture
	leg_r.texture = new_skin.texture
	foot_r.texture = new_skin.texture
	torso.texture = new_skin.texture

func update_action():
	match cur_action:
		action_states.IDLE:
			if is_backwards:
				character_anim_player.play("Idle_back")
			else:
				character_anim_player.play("Idle_front")
		action_states.WALKING:
			if is_backwards:
				character_anim_player.play("Walk_back")
			else:
				character_anim_player.play("Walk_front")
		action_states.DEAD:
			character_anim_player.play("Die")
			
func update_expression():
	match cur_expression:
		expression_states.POKER:
			expression_anim_player.play("poker_face")
		expression_states.ANGRY:
			expression_anim_player.play("angry_face")
		expression_states.SUPRISED:
			expression_anim_player.play("suprised_face")
		expression_states.PROUD:
			expression_anim_player.play("goated_face")

func _Blink() -> void:
	var original_expression :String = expression_anim_player.current_animation
	expression_anim_player.play("blink")
	await expression_anim_player.animation_finished
	expression_anim_player.play(original_expression)#may seem redunctant but whatever
	update_expression()
func damage():
	var original_expression :String = expression_anim_player.current_animation
	expression_anim_player.play("angry_face")
	$SkinViewport/Pivot/Damage_Anim_Player.play("damage")
	await $SkinViewport/Pivot/Damage_Anim_Player.animation_finished
	expression_anim_player.play(original_expression)#may seem redunctant but whatever
	update_expression()
func heal():
	var original_expression :String = expression_anim_player.current_animation
	expression_anim_player.play("goated_face")
	$SkinViewport/Pivot/Damage_Anim_Player.play("heal")
	await $SkinViewport/Pivot/Damage_Anim_Player.animation_finished
	expression_anim_player.play(original_expression)#may seem redunctant but whatever
	update_expression()
