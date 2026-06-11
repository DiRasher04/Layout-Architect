extends Control

# Ссылки на сцены
@export var game_scene: PackedScene
@export var settings_scene: PackedScene

# Ссылки на кнопки
@onready var start_button := $VBoxContainer/StartButton as Button
@onready var settings_button := $VBoxContainer/SettingsButton as Button
@onready var exit_button := $VBoxContainer/ExitButton as Button

func _ready():
	# Подключаем сигналы кнопок
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Делаем видимым мышь
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_start_pressed():
	# Загружаем игровую сцену
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		print("Ошибка: game_scene не назначена в инспекторе!")

func _on_settings_pressed():
	# Открываем меню настроек
	if settings_scene:
		get_tree().change_scene_to_packed(settings_scene)
	else:
		print("Ошибка: settings_scene не назначена в инспекторе!")

func _on_exit_pressed():
	# Выход из игры
	get_tree().quit()
