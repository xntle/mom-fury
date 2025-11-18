extends Camera2D

@export var target: Node2D          
@export var follow_speed: float = 5 

func _process(delta: float) -> void:
	if target == null:
		return

	# Smoothly move camera toward the player
	global_position = global_position.lerp(
		target.global_position,
		follow_speed * delta
	)
