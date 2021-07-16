extends ProgressBar

onready var _playerHealth = get_node("/root/World/Player/Stats")
	
func _ready():
	_playerHealth.connect("health_changed", self, "_on_character_damage_taken")

func _on_character_damage_taken(impact):
	# Update health bar according to character's current HP
	
	value = _playerHealth.health
