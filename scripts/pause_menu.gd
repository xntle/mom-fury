extends Control

func _ready():
	# adjust node paths if your names differ
	$VBoxContainer2/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer2/QuitButton.pressed.connect(_on_quit_pressed)
	visible = false
	

func _on_resume_pressed():
	if get_tree().paused == true:
		get_tree().paused = false
		visible = false

func _on_quit_pressed():
	if get_tree().paused == true:
		get_tree().quit()

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused
