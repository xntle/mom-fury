extends CharacterBody2D

signal enemy_destroyed(enemy)

@export var health: int = 100
@export var speed: float = 50.0
@export var damage: float = 10.0

var player: CharacterBody2D
var push_dir: Vector2 = Vector2(0, 0)
var push_strength: float = 0.0
var push_timer: float = 0.0
var bounce_timer: float = 0.0
var default_bounce_timer: float = 0.25

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var damage_text: Label = $DamageTextContainer/DamageText
@onready var anime_state_machine = animation_tree["parameters/playback"]
@onready var blood_particle = preload("res://scenes/blood_particle.tscn")

func _ready():
	damage_text.visible = false

func setup(pos: Vector2, _player: CharacterBody2D):
	position = pos
	player = _player

func _physics_process(delta):
	var dir = (player.global_position - global_position).normalized()
	bounce_timer = max(0.0,bounce_timer-delta)
	#This feels hella clunky cuz the velocity jumps to 0 instead of decelerating ima make it work better later
	if bounce_timer == 0.0: ##Basically if it's not currently bouncing then it will move
		position += dir * delta * speed
	elif bounce_timer >= 0.1: ##If the bounce timer is more than 0.1s it will bounce backwards. So for the last 0.1s after bouncing it will stand still to simulate recoil.
		position -= dir * delta * speed * 2 ##IDEALLY it should linearly increase from -2 to 1(as a factor of the dir vector). Rather than jumping from -2 to 0 to 1. U got that Kyle
	# Handle push
	push_back(delta)

func get_hit(damage: int, bullet_trans: Transform2D):
	health -= damage
	damage_text.text = str(damage)
	animation_tree['parameters/conditions/is_damaged'] = true
	if health <= 0:
		animation_tree['parameters/conditions/is_destroyed'] = true
	# Bleeding effect
	var bleeding_effect = blood_particle.instantiate()
	get_tree().root.add_child(bleeding_effect)
	bleeding_effect.setup(bullet_trans)
	set_push(Vector2.RIGHT.rotated(bullet_trans.get_rotation()), 150.0, 0.1)

func destroy():
	enemy_destroyed.emit(self)
	queue_free()

func set_push(dir: Vector2, strength: float, timer: float):
	push_dir = -dir
	push_strength = strength
	push_timer = timer

func push_back(delta: float):
	if push_timer > 0.0:
		position -= push_dir * push_strength * delta
		push_timer -= delta
	else:
		push_timer = 0.0

func _on_animation_tree_animation_finished(_anim_name):
	if anime_state_machine.get_current_node() == "get_damage":
		anime_state_machine.travel("move")
		animation_tree['parameters/conditions/is_damaged'] = false
	elif anime_state_machine.get_current_node() == "destroy":
		animation_tree['parameters/conditions/is_destroyed'] = false
		destroy()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destroy":
		#animation_tree['parameters/conditions/is_destroyed'] = false
		pass

#Logic for when the enemy collides with the player.
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player and body.is_intangible == false:
		player.take_damage(damage)
		bounce_timer+=default_bounce_timer
