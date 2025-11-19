# RicechineGun.gd
extends Weapon
class_name RicechineGun

@export var bullets_per_burst: int = 3
@export var spread_deg: float = 6.0

func _ready():
	weapon_type = WeaponType.RICECHINE_GUN
	weapon_name = "Ricechine Gun"

func fire(spawn_xform: Transform2D, aim_dir: Vector2, parent: Node) -> bool:
	if not can_fire():
		return false
	if bullet_scene == null:
		return false

	_start_cooldown()

	for i in range(bullets_per_burst):
		var t: float
		if bullets_per_burst == 1:
			t = 0.5
		else:
			t = float(i) / float(bullets_per_burst - 1)
		var angle_offset = deg_to_rad(lerp(-spread_deg * 0.5, spread_deg * 0.5, t))
		var dir = aim_dir.rotated(angle_offset).normalized()

		var bullet = bullet_scene.instantiate()
		bullet.global_transform = spawn_xform
		if bullet.has_variable("direction"):
			bullet.direction = dir
		if bullet.has_variable("damage"):
			bullet.damage = damage
		parent.add_child(bullet)

	return true
