extends Control

func _ready():
	# adjust node paths if your names differ
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn") # <-- your game scene path

func _on_quit_pressed():
	get_tree().quit()
