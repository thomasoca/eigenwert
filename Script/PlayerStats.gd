extends Control

export var max_health = 100
onready var health = max_health setget set_health
export var max_stamina = 100
onready var stamina = max_stamina setget set_stamina

signal no_health
signal health_changed(value)

signal no_stamina
signal stamina_changed(value)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")
		
func set_stamina(value):
	stamina = value
	emit_signal("stamina_changed", stamina)
	if health <= 0:
		emit_signal("no_stamina")
