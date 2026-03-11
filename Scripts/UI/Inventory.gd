extends CanvasLayer
class_name BackpackInventory

@export var slot_scene :PackedScene
@onready var AnimTree: AnimationTree = $AnimationTree
@onready var anim_state = AnimTree.get("parameters/playback")
@onready var slotContainer :VBoxContainer= $Control/SlotBar/ScrollContainer/VBoxContainer
var data_backup

enum InventoryState {
	CLOSED,
	CLOSING,
	OPENING
}
@onready var cur_state:InventoryState=InventoryState.CLOSED


func _ready() -> void:
	GameManager.ui_backpack = self
	compact_inventory()
	if GameManager.cur_inventory.size()<5:
		GameManager.cur_inventory.resize(5)
	updateInventoryItemDisplay()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Inventory"):
		if cur_state==InventoryState.CLOSED or cur_state==InventoryState.CLOSING:
			CursorManager.set_cursor(CursorManager.types.DEFAULT)
			$middle.mouse_filter = $middle.MOUSE_FILTER_IGNORE
			updateInventoryState(InventoryState.OPENING)
		else:
			CursorManager.set_cursor(CursorManager.types.CROSSHAIR)
			$middle.mouse_filter = $middle.MOUSE_FILTER_STOP
			updateInventoryState(InventoryState.CLOSING)
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


func updateInventoryState(state:InventoryState):
	match state:
		InventoryState.CLOSED:
			print("closed")
			anim_state.travel("Closed")

		InventoryState.CLOSING:
			print("closing")
			anim_state.travel("Closing")

		InventoryState.OPENING:
			print("opening")
			anim_state.travel("Opening")

	cur_state = state


func ensure_slots(amount:int):
	while slotContainer.get_child_count() < amount:
		var new_slot:InventorySlot = slot_scene.instantiate()
		new_slot.slot_index = slotContainer.get_child_count()
		slotContainer.add_child(new_slot)


func updateInventoryItemDisplay():
	var inventory:Array[InventoryItem] = GameManager.cur_inventory
	
	ensure_slots(inventory.size())
	
	for i in inventory.size():
		var slot:InventorySlot = slotContainer.get_child(i)
		slot.slot_item = inventory[i]
		slot.update_ui_display()

func compact_inventory():

	var inv = GameManager.cur_inventory
	var new_inv : Array[InventoryItem] = []

	# pega apenas itens válidos
	for item in inv:
		if item != null:
			new_inv.append(item)


	GameManager.cur_inventory = new_inv



func _on_button_pressed() -> void:
	if cur_state==InventoryState.CLOSED or cur_state==InventoryState.CLOSING:
		CursorManager.set_cursor(CursorManager.types.DEFAULT)
		$middle.mouse_filter = $middle.MOUSE_FILTER_IGNORE
		updateInventoryState(InventoryState.OPENING)
	else:
		CursorManager.set_cursor(CursorManager.types.CROSSHAIR)
		$middle.mouse_filter = $middle.MOUSE_FILTER_STOP
		updateInventoryState(InventoryState.CLOSING)

func _on_panel_mouse_entered() -> void:
	CursorManager.set_cursor(CursorManager.types.DEFAULT)

func _on_panel_mouse_exited() -> void:
	if cur_state == InventoryState.CLOSING or cur_state == InventoryState.CLOSED:
		CursorManager.set_cursor(CursorManager.types.CROSSHAIR)
		print("mouse exited")
	else:
		CursorManager.set_cursor(CursorManager.types.DEFAULT)
