# Weapon.gd
extends Node2D
class_name Weapon

enum WeaponType { SLIPPER, RICECHINE_GUN, BROOM }

@export var weapon_type: WeaponType
@export var weapon_name: String = "Unnamed"
@export var fire_rate: float = 3.0         # attacks per second (ranged or melee)
@export var bullet_scene: PackedScene      # only used for ranged
@export var attack_range: float = 40.0     # mostly for broom
@export var damage: int = 1

var _cooldown := 0.0

func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown -= delta

func can_fire() -> bool:
	return _cooldown <= 0.0

func fire(spawn_xform: Transform2D, aim_dir: Vector2, parent: Node) -> bool:
	# base version does nothing – each weapon overrides this
	return false

func _start_cooldown():
	_cooldown = 1.0 / max(fire_rate, 0.001)
