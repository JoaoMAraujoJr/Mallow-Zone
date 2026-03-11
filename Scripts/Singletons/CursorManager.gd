extends Node
class_name UtilityCursor
signal cursor_changed(cursor_style,cursor_type)

enum types {
	DEFAULT,
	CROSSHAIR,
	PHONE
}

@export var default_CS : CursorStyle = preload("res://Scripts/Resources/cursors/default_cursor.tres")
@export var crosshair_CS : CursorStyle = preload("res://Scripts/Resources/cursors/crosshair_cursor.tres")
@export var phone_CS : CursorStyle = preload("res://Scripts/Resources/cursors/phone_cursor.tres")

var cur_cursorType : types = types.DEFAULT
var cur_cursorStyle : CursorStyle = default_CS


func set_cursor(type:types):
	print("cursor change method called \n" + "curso type is now " + str(type))
	match type:
		types.DEFAULT:
			GameManager.can_shoot =false
			cur_cursorStyle =default_CS
			cursor_changed.emit(default_CS,types.DEFAULT)
			Input.set_custom_mouse_cursor(default_CS.arrow_cursor,Input.CURSOR_ARROW)
			Input.set_custom_mouse_cursor(default_CS.unpressed_cursor,Input.CURSOR_POINTING_HAND)
			Input.set_custom_mouse_cursor(default_CS.pressed_cursor,Input.CURSOR_CAN_DROP)
			Input.set_custom_mouse_cursor(default_CS.pressed_cursor,Input.CURSOR_DRAG)
			Input.set_custom_mouse_cursor(default_CS.pressed_cursor,Input.CURSOR_FORBIDDEN)
			Input.set_custom_mouse_cursor(default_CS.loading_cursor,Input.CURSOR_BUSY)
		types.CROSSHAIR:
			GameManager.can_shoot =true
			cur_cursorStyle =crosshair_CS
			cursor_changed.emit(crosshair_CS,types.CROSSHAIR)
			Input.set_custom_mouse_cursor(crosshair_CS.arrow_cursor,Input.CURSOR_ARROW)
			Input.set_custom_mouse_cursor(crosshair_CS.unpressed_cursor,Input.CURSOR_POINTING_HAND)
			Input.set_custom_mouse_cursor(crosshair_CS.pressed_cursor,Input.CURSOR_CAN_DROP)
			Input.set_custom_mouse_cursor(crosshair_CS.pressed_cursor,Input.CURSOR_DRAG)
			Input.set_custom_mouse_cursor(crosshair_CS.pressed_cursor,Input.CURSOR_FORBIDDEN)
			Input.set_custom_mouse_cursor(crosshair_CS.loading_cursor,Input.CURSOR_BUSY)
		types.PHONE:
			GameManager.can_shoot =false
			cur_cursorStyle =phone_CS
			cursor_changed.emit(phone_CS,types.PHONE)
			Input.set_custom_mouse_cursor(phone_CS.arrow_cursor,Input.CURSOR_ARROW)
			Input.set_custom_mouse_cursor(phone_CS.unpressed_cursor,Input.CURSOR_POINTING_HAND)
			Input.set_custom_mouse_cursor(phone_CS.pressed_cursor,Input.CURSOR_CAN_DROP)
			Input.set_custom_mouse_cursor(phone_CS.pressed_cursor,Input.CURSOR_DRAG)
			Input.set_custom_mouse_cursor(phone_CS.pressed_cursor,Input.CURSOR_FORBIDDEN)
			Input.set_custom_mouse_cursor(phone_CS.loading_cursor,Input.CURSOR_BUSY)
	print ("cursor Style is now "+str(cur_cursorStyle))
func _input(event: InputEvent) -> void:
	if cur_cursorStyle == null:
		return

	if event.is_action_pressed("Mouse_left") and cur_cursorStyle.pressed_cursor:
		Input.set_custom_mouse_cursor(cur_cursorStyle.pressed_cursor)

	elif event.is_action_released("Mouse_left") and cur_cursorStyle.unpressed_cursor:
		Input.set_custom_mouse_cursor(cur_cursorStyle.unpressed_cursor)
