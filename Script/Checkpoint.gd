extends SwitchItem


func interaction_interact(interactionComponentParent : Node) -> void:
	$Lantern/AnimationPlayer.play("activate")

func _ready():
	$Lantern/AnimationPlayer.stop()
	$Lantern.frame = 0

