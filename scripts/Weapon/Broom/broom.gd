# BroomWeapon.gd
extends Weapon
class_name BroomWeapon

@export var hitbox: Area2D       

func _ready():
	weapon_type = WeaponType.BROOM
	weapon_name = "Broom"

func fire(spawn_xform: Transform2D, aim_dir: Vector2, parent: Node) -> bool:
	if not can_fire():
		return false

	_start_cooldown()

	# Simple example: use hitbox overlapping bodies
	if hitbox:
		for body in hitbox.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(damage)

	# you can also play broom swing animation here
	return true
