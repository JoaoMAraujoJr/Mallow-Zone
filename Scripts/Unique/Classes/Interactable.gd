extends Node
class_name Interactable


enum UsageTypes{
	INFINITY,
	MULTIPLE,
	ONCE,
	NONE
}

enum InteractionTypes{
	BUTTON,
	APPROACH,
	SHOT,
	SHOTANDBUTTON
}

@export var usageType : UsageTypes = UsageTypes.INFINITY
@export var interactionType : InteractionTypes = InteractionTypes.BUTTON

@export var maxAmmountOfInteractions : int = 99
var currentInteractionCount : int = 0 :
	set(value):
		if UsageTypes.MULTIPLE:
			currentInteractionCount = clamp(value,0 , maxAmmountOfInteractions)
		else:
			currentInteractionCount = value
	get():
		return currentInteractionCount

@export var cooldownTimeInSeconds : float = 0.5
@onready var cooldownTimer : Timer = Timer.new()

@export var canInteract : bool = true
@onready var interactionArea :Area2D

#check for interactions
func checkAreasInInteractable() -> void:
	if !interactionArea:
		print("InteractionArea not found, or not setted correctly")
	if (!canInteract) or (usageType == UsageTypes.NONE):
		return

	for area in interactionArea.get_overlapping_areas():
		match interactionType:
			InteractionTypes.BUTTON:
				if area.is_in_group("PlayerArea"):
					if Input.is_action_just_pressed("Interact"):
						Interact()

			InteractionTypes.APPROACH:
				if area.is_in_group("PlayerArea"):
					Interact()

			InteractionTypes.SHOT:
				if area.is_in_group("canInteract"):
					Interact()

			InteractionTypes.SHOTANDBUTTON:
				if area.is_in_group("canInteract"):
					Interact()
				if area.is_in_group("PlayerArea"):
					if Input.is_action_just_pressed("Interact"):
						Interact()

#actual interaction logic
func Interact():
	if usageType == UsageTypes.NONE:
		return
	if (usageType == UsageTypes.MULTIPLE and (currentInteractionCount == maxAmmountOfInteractions)):
		usageType = UsageTypes.NONE
		return
	if (usageType == UsageTypes.ONCE and currentInteractionCount >= 1):
		usageType = UsageTypes.NONE
		return
	canInteract = false
	cooldownTimer.start()
	currentInteractionCount +=1

func _ready():
	#creates timer in the scene
	add_child(cooldownTimer)
	cooldownTimer.wait_time = cooldownTimeInSeconds
	cooldownTimer.timeout.connect(func(): canInteract = true)
	
