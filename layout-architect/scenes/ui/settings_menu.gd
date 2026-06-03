extends Control

# Путь для сохранения файла настроек
const SETTINGS_PATH = "user://settings.cfg"

# Кнопки (назначаешь в инспекторе или через @onready)
@onready var save_button = $SaveButton
@onready var back_button = $BackButton


func _ready():
	# Загружаем сохраненные настройки при запуске
	load_settings()
	
	# Подключаем сигналы кнопок
	save_button.pressed.connect(_on_save_pressed)
	back_button.pressed.connect(_on_back_pressed)


# СОХРАНЕНИЕ НАСТРОЕК
func _on_save_pressed():
	var config = ConfigFile.new()
	
	# ========== BSP НАСТРОЙКИ ==========
	# Получаем значения из твоих слайдеров/полей
	# ПРИМЕР: config.set_value("bsp", "width", $WidthSlider.value)
	# ПРИМЕР: config.set_value("bsp", "height", $HeightSlider.value)
	
	# ========== CA НАСТРОЙКИ ==========
	# ПРИМЕР: config.set_value("ca", "density", $DensitySlider.value)
	
	# ========== ГИБРИДНЫЕ НАСТРОЙКИ ==========
	# ПРИМЕР: config.set_value("hybrid", "iterations", $HybridIterationsSlider.value)
	
	# Сохраняем файл
	config.save(SETTINGS_PATH)

	
	# Опционально: показать визуальное уведомление
	_show_saved_notification()


# ЗАГРУЗКА НАСТРОЕК
func load_settings():
	var config = ConfigFile.new()
	
	# Если файла нет — используем значения по умолчанию (ничего не делаем)
	if not config.load(SETTINGS_PATH) == OK:
		return
	
	# ========== BSP НАСТРОЙКИ ==========
	# ПРИМЕР: $WidthSlider.value = config.get_value("bsp", "width", 60)
	# ПРИМЕР: $HeightSlider.value = config.get_value("bsp", "height", 60)
	
	# ========== CA НАСТРОЙКИ ==========
	# ПРИМЕР: $DensitySlider.value = config.get_value("ca", "density", 0.45)
	
	# ========== ГИБРИДНЫЕ НАСТРОЙКИ ==========
	# ПРИМЕР: $HybridIterationsSlider.value = config.get_value("hybrid", "iterations", 3)


# ВЫХОД В ГЛАВНОЕ МЕНЮ
func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")


# ОПЦИОНАЛЬНО: визуальное уведомление о сохранении
func _show_saved_notification():
	# Меняем текст кнопки на секунду
	var original_text = save_button.text
	save_button.text = "Сохранено!"
	await get_tree().create_timer(1.0).timeout
	save_button.text = original_text
