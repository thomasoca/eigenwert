extends InteractableItem
class_name SwitchItem

export var interaction_texture : Texture = preload("res://Assets/interactionhand.png")

func interaction_get_texture() -> Texture:
	return interaction_texture

func interaction_get_text() -> String:
	return "Activate checkpoint"
