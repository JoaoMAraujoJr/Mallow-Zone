extends Node2D
class_name UtilityCursor

enum CursorTypeList{
	DEFAULT,
	CROSSHAIR,
	PHONE
}

@export var default_CS :CursorStyle
@export var crosshair_CS :CursorStyle
@export var phone_CS:CursorStyle

@onready var cursor_spr :Sprite2D = $cursorSprite
@onready var crosshair_spr :Sprite2D = $crosshairSprite

@export var cur_cursorType:CursorTypeList = CursorTypeList.DEFAULT
var cur_cursorStyle:CursorStyle


func _ready() -> void:
	matchCursorType()
	GameManager.game_cursor = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	pass

func matchCursorType():
	match cur_cursorType:
		CursorTypeList.DEFAULT:
			if default_CS and cur_cursorStyle != default_CS:
				cur_cursorStyle = default_CS
				cursor_spr.visible = true
				crosshair_spr.visible = false
				cursor_spr.texture = cur_cursorStyle.unpressed_cursor
		CursorTypeList.PHONE:
			if phone_CS and cur_cursorStyle != phone_CS:
				cur_cursorStyle = phone_CS
				cursor_spr.visible = true
				crosshair_spr.visible = false
				cursor_spr.texture = cur_cursorStyle.unpressed_cursor
		CursorTypeList.CROSSHAIR:
			if crosshair_CS and cur_cursorStyle != crosshair_CS:
				cur_cursorStyle = crosshair_CS
				cursor_spr.visible = false
				crosshair_spr.visible = true
				crosshair_spr.texture = cur_cursorStyle.unpressed_cursor

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Mouse_left") and cur_cursorStyle.pressed_cursor:
		cursor_spr.texture = cur_cursorStyle.pressed_cursor
		crosshair_spr.texture = cur_cursorStyle.pressed_cursor
	elif event.is_action_released("Mouse_left") and cur_cursorStyle.unpressed_cursor:
		cursor_spr.texture = cur_cursorStyle.unpressed_cursor
		crosshair_spr.texture = cur_cursorStyle.unpressed_cursor
