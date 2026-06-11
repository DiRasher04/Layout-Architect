extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var save_button: Button = $SaveButton
@onready var back_button: Button = $BackButton

var save_button_original_text: String = ""

func _ready():
	if save_button:
		save_button_original_text = save_button.text
		save_button.pressed.connect(_on_save_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_save_pressed():
	if tab_container:
		Global.selected_algorithm = tab_container.current_tab
		print("Сохранён алгоритм: ", Global.selected_algorithm)
	
	if save_button:
		save_button.text = "Сохранено"
		save_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		save_button.text = save_button_original_text
		save_button.disabled = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
