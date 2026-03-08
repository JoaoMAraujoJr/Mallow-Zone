extends CanvasLayer

var data_backup

func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_DRAG_BEGIN:
		data_backup= get_viewport().gui_get_drag_data()
	if what == Node.NOTIFICATION_DRAG_END:
		if data_backup:
			if data_backup is Dictionary and data_backup.has("source_slot"):
				var source = data_backup["source_slot"]
				if source.dragging:
					source.item_sprite.show()
					source.item_shadow.show()
