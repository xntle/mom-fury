extends Label

@export var player: CharacterBody2D

func _ready():
	text = "Health: %d" % player.current_health
	if player:
		player.connect("health_changed", update_health)
		update_health(player.current_health)

func update_health(new_health):
	text = "Health: %d" % new_health
