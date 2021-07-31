extends Area2D


func _input(event):
	if event.is_action_pressed("interact") and len(get_overlapping_bodies()) > 1:
		find_and_use_dialogue()
		
func find_and_use_dialogue():
	var dialogue_player = get_node_or_null("DialoguePlayer")
	
	if dialogue_player:
		dialogue_player.play()
