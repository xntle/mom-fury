extends CharacterBody2D

@export var speed: float = 360.0
@export var lr_flag: bool = true
@export var rotate_flag: bool = true
@export var max_health: float = 100.0
# --- Roll system ---
@export var roll_speed: float = 900.0
@export var roll_time: float = 0.18
@export var roll_cooldown: float = 0.4
var 	current_health=max_health
var is_rolling: bool = false
var roll_timer: float = 0.0
var roll_cd: float = 0.0
var roll_dir: Vector2 = Vector2.ZERO
var is_intangible: bool = false

var screen_size
var lr: bool = true
var aim_pos: Vector2 = Vector2.ZERO
var is_shot_cd: bool = false
var push_dir: Vector2 = Vector2.ZERO
var push_strength: float = 0.0
var push_timer: float = 0.0

signal health_changed(new_health: int)

@onready var body_lr: Polygon2D = $BodyLR
@onready var body_rotate: Polygon2D = $BodyRotate
@onready var body_lr_player: AnimationPlayer = $BodyLRPlayer
@onready var body_rotete_player: AnimationPlayer = $BodyRotatePlayer
@onready var move_trail_effect: GPUParticles2D = $MovementTrailEffect
@onready var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var bullet_spawn_pos: Node2D = $BodyRotate/BulletSpawnPoint
@onready var shot_timer: Timer = $ShotTimer
@onready var shot_effect: GPUParticles2D = $BodyRotate/ShootingEffect
@onready var body_lr_collider: CollisionPolygon2D = $CollisionBodyLR
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _physics_process(delta):
	velocity = Vector2.ZERO

	# --- Movement input ---
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity != Vector2.ZERO:
		velocity = velocity.normalized() * speed

	# --- Roll cooldown ---
	if roll_cd > 0.0:
		roll_cd -= delta

	# --- Rolling ---
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0.0:
			is_rolling = false
			is_intangible = false
			roll_cd = roll_cooldown
	else:
		# Try to start a roll
		if Input.is_action_just_pressed("roll") and roll_cd <= 0.0:
			if velocity != Vector2.ZERO:
				roll_dir = velocity.normalized()       # 8-way roll direction
			else:
				roll_dir = Vector2.RIGHT if lr else Vector2.LEFT

			is_rolling = true
			is_intangible = true
			roll_timer = roll_time

	# Use roll velocity if rolling
	if is_rolling:
		velocity = roll_dir * roll_speed
		move_trail_effect.emitting = true
	else:
		move_trail_effect.emitting = velocity != Vector2.ZERO

	# --- Shooting ---
	if Input.is_action_pressed("shot") and not is_shot_cd:
		shoot()
		is_shot_cd = true
		shot_timer.start(0.2)

	update_body_lr()
	push_back(delta)

	# Keep player inside screen
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)

	position+=velocity*delta
	
	# Damage and death logic
	if current_health >= max_health:
		current_health = max_health
	if current_health <= 0.0:
		current_health = 0.0
		#Add death logic here
		get_tree().quit()

func _input(event):
	if event is InputEventMouseMotion:
		update_body_rotate(event.position)

func setup(pos: Vector2):
	position = pos
	show()
	
func take_damage(amount: int) -> void:
	current_health -= amount
	emit_signal("health_changed", current_health)

func update_body_lr():
	if not lr_flag:
		return

	if velocity.length() > 0:
		if lr:
			body_lr_player.play("MoveR")
		else:
			body_lr_player.play("MoveL")

		if velocity.x > 0:
			body_lr_player.play("MoveR")
			body_lr_collider.scale.x = -1
			lr = true
		elif velocity.x < 0:
			body_lr_player.play("MoveL")
			body_lr_collider.scale.x = 1
			lr = false
	else:
		if lr:
			body_lr_player.play("IdleR")
		else:
			body_lr_player.play("IdleL")

func update_body_rotate(mouse_pos: Vector2):
	if not rotate_flag:
		return
	body_rotate.look_at(mouse_pos)
	aim_pos = mouse_pos.normalized()

func shoot():
	body_rotete_player.play("Shot")
	var bullet = bullet_scene.instantiate()
	bullet.setup(bullet_spawn_pos.global_transform)
	get_tree().root.add_child(bullet)
	shot_effect.emitting = true
	audio_player.play()

func set_push(dir: Vector2, strength: float, timer: float):
	push_dir = dir
	push_strength = strength
	push_timer = timer

func push_back(delta: float):
	if push_timer > 0.0:
		position -= push_dir * push_strength * delta
		push_timer -= delta
	else:
		push_timer = 0.0

func _on_shot_timer_timeout():
	is_shot_cd = false
