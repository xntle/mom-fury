extends Weapon
class_name Slipper

func _ready():
	weapon_type = WeaponType.SLIPPER
	weapon_name = "Slipper"

func fire(spawn_xform: Transform2D, aim_dir: Vector2, parent: Node) -> bool:
	if not can_fire():
		return false

	if bullet_scene == null:
		return false

	_start_cooldown()

	var bullet = bullet_scene.instantiate()
	bullet.global_transform = spawn_xform
	if bullet.has_variable("direction"):
		bullet.direction = aim_dir.normalized()
	if bullet.has_variable("damage"):
		bullet.damage = damage

	parent.add_child(bullet)
	return true
