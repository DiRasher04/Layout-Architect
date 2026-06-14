extends Control

@onready var tab_container: TabContainer = $TabContainer
@onready var save_button: Button = $SaveButton
@onready var back_button: Button = $BackButton

# BSP параметры - слайдеры
@onready var min_room_size_slider = $TabContainer/BSP/Panel/min_room_size_slider
@onready var min_room_size_value = $TabContainer/BSP/Panel/min_room_size_value

@onready var max_room_size_slider = $TabContainer/BSP/Panel/max_room_size_slider
@onready var max_room_size_value = $TabContainer/BSP/Panel/max_room_size_value

@onready var max_split_iterations_slider = $TabContainer/BSP/Panel/max_split_iterations_slider
@onready var max_split_iterations_value = $TabContainer/BSP/Panel/max_split_iterations_value

@onready var corridor_thickness_slider = $TabContainer/BSP/Panel/corridor_thickness_slider
@onready var corridor_thickness_value = $TabContainer/BSP/Panel/corridor_thickness_value

@onready var corridor_variation_slider = $TabContainer/BSP/Panel/corridor_variation_slider
@onready var corridor_variation_value = $TabContainer/BSP/Panel/corridor_variation_value

@onready var corridor_jitter_slider = $TabContainer/BSP/Panel/corridor_jitter_slider
@onready var corridor_jitter_value = $TabContainer/BSP/Panel/corridor_jitter_value

@onready var add_mid_points_checkbox = $TabContainer/BSP/Panel/add_mid_points_checkbox

# Cellular Automata параметры - слайдеры (ОБНОВЛЁННЫЕ ПУТИ)
@onready var cellular_fill_probability_slider = $TabContainer/CellularAutomata/Panel/fill_probability_slider
@onready var cellular_fill_probability_value = $TabContainer/CellularAutomata/Panel/fill_probability_value

@onready var cellular_iterations_slider = $TabContainer/CellularAutomata/Panel/iterations_slider
@onready var cellular_iterations_value = $TabContainer/CellularAutomata/Panel/iterations_value

@onready var cellular_birth_limit_slider = $TabContainer/CellularAutomata/Panel/birth_limit_slider
@onready var cellular_birth_limit_value = $TabContainer/CellularAutomata/Panel/birth_limit_value

@onready var cellular_death_limit_slider = $TabContainer/CellularAutomata/Panel/death_limit_slider
@onready var cellular_death_limit_value = $TabContainer/CellularAutomata/Panel/death_limit_value

# Hybrid параметры - слайдеры
@onready var hybrid_min_room_size_slider = $TabContainer/Hybrid/Panel/min_room_size_slider
@onready var hybrid_min_room_size_value = $TabContainer/Hybrid/Panel/min_room_size_value

@onready var hybrid_max_room_size_slider = $TabContainer/Hybrid/Panel/max_room_size_slider
@onready var hybrid_max_room_size_value = $TabContainer/Hybrid/Panel/max_room_size_value

@onready var hybrid_cellular_noise_slider = $TabContainer/Hybrid/Panel/cellular_noise_slider
@onready var hybrid_cellular_noise_value = $TabContainer/Hybrid/Panel/cellular_noise_value

# Общие параметры (лежат в корне сцены)
@onready var width_slider = $width_slider
@onready var width_value = $width_value
@onready var height_slider = $height_slider
@onready var height_value = $height_value
@onready var wall_thickness_slider = $wall_thickness_slider
@onready var wall_thickness_value = $wall_thickness_value

var save_button_original_text: String = ""

func _ready():
	if save_button:
		save_button_original_text = save_button.text
		save_button.pressed.connect(_on_save_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	_setup_bsp_sliders()
	_setup_cellular_sliders()
	_setup_hybrid_sliders()
	_setup_common_sliders()
	_load_saved_values()

func _setup_bsp_sliders():
	if min_room_size_slider and min_room_size_value:
		min_room_size_slider.min_value = 3
		min_room_size_slider.max_value = 10
		min_room_size_slider.value_changed.connect(_on_min_room_size_changed)
		_update_slider_label(min_room_size_slider, min_room_size_value)
	
	if max_room_size_slider and max_room_size_value:
		max_room_size_slider.min_value = 10
		max_room_size_slider.max_value = 30
		max_room_size_slider.value_changed.connect(_on_max_room_size_changed)
		_update_slider_label(max_room_size_slider, max_room_size_value)
	
	if max_split_iterations_slider and max_split_iterations_value:
		max_split_iterations_slider.min_value = 1
		max_split_iterations_slider.max_value = 12
		max_split_iterations_slider.value_changed.connect(_on_max_split_iterations_changed)
		_update_slider_label(max_split_iterations_slider, max_split_iterations_value)
	
	if corridor_thickness_slider and corridor_thickness_value:
		corridor_thickness_slider.min_value = 1
		corridor_thickness_slider.max_value = 5
		corridor_thickness_slider.value_changed.connect(_on_corridor_thickness_changed)
		_update_slider_label(corridor_thickness_slider, corridor_thickness_value)
	
	if corridor_variation_slider and corridor_variation_value:
		corridor_variation_slider.min_value = 0
		corridor_variation_slider.max_value = 15
		corridor_variation_slider.value_changed.connect(_on_corridor_variation_changed)
		_update_slider_label(corridor_variation_slider, corridor_variation_value)
	
	if corridor_jitter_slider and corridor_jitter_value:
		corridor_jitter_slider.min_value = 0.0
		corridor_jitter_slider.max_value = 1.0
		corridor_jitter_slider.step = 0.01
		corridor_jitter_slider.value_changed.connect(_on_corridor_jitter_changed)
		_update_slider_label_float(corridor_jitter_slider, corridor_jitter_value)

func _setup_cellular_sliders():
	if cellular_fill_probability_slider and cellular_fill_probability_value:
		cellular_fill_probability_slider.min_value = 0.4
		cellular_fill_probability_slider.max_value = 0.6
		cellular_fill_probability_slider.step = 0.01
		cellular_fill_probability_slider.value_changed.connect(_on_cellular_fill_probability_changed)
		_update_slider_label_percent(cellular_fill_probability_slider, cellular_fill_probability_value)
	
	if cellular_iterations_slider and cellular_iterations_value:
		cellular_iterations_slider.min_value = 1
		cellular_iterations_slider.max_value = 15
		cellular_iterations_slider.value_changed.connect(_on_cellular_iterations_changed)
		_update_slider_label(cellular_iterations_slider, cellular_iterations_value)
	
	if cellular_birth_limit_slider and cellular_birth_limit_value:
		cellular_birth_limit_slider.min_value = 0
		cellular_birth_limit_slider.max_value = 8
		cellular_birth_limit_slider.value_changed.connect(_on_cellular_birth_limit_changed)
		_update_slider_label(cellular_birth_limit_slider, cellular_birth_limit_value)
	
	if cellular_death_limit_slider and cellular_death_limit_value:
		cellular_death_limit_slider.min_value = 0
		cellular_death_limit_slider.max_value = 8
		cellular_death_limit_slider.value_changed.connect(_on_cellular_death_limit_changed)
		_update_slider_label(cellular_death_limit_slider, cellular_death_limit_value)

func _setup_hybrid_sliders():
	if hybrid_min_room_size_slider and hybrid_min_room_size_value:
		hybrid_min_room_size_slider.min_value = 3
		hybrid_min_room_size_slider.max_value = 10
		hybrid_min_room_size_slider.value_changed.connect(_on_hybrid_min_room_size_changed)
		_update_slider_label(hybrid_min_room_size_slider, hybrid_min_room_size_value)
	
	if hybrid_max_room_size_slider and hybrid_max_room_size_value:
		hybrid_max_room_size_slider.min_value = 10
		hybrid_max_room_size_slider.max_value = 30
		hybrid_max_room_size_slider.value_changed.connect(_on_hybrid_max_room_size_changed)
		_update_slider_label(hybrid_max_room_size_slider, hybrid_max_room_size_value)
	
	if hybrid_cellular_noise_slider and hybrid_cellular_noise_value:
		hybrid_cellular_noise_slider.min_value = 0.0
		hybrid_cellular_noise_slider.max_value = 1.0
		hybrid_cellular_noise_slider.step = 0.01
		hybrid_cellular_noise_slider.value_changed.connect(_on_hybrid_cellular_noise_changed)
		_update_slider_label_float(hybrid_cellular_noise_slider, hybrid_cellular_noise_value)

func _setup_common_sliders():
	if width_slider and width_value:
		width_slider.min_value = 20
		width_slider.max_value = 250
		width_slider.value_changed.connect(_on_width_changed)
		_update_slider_label(width_slider, width_value)
	
	if height_slider and height_value:
		height_slider.min_value = 20
		height_slider.max_value = 250
		height_slider.value_changed.connect(_on_height_changed)
		_update_slider_label(height_slider, height_value)
	
	if wall_thickness_slider and wall_thickness_value:
		wall_thickness_slider.min_value = 1
		wall_thickness_slider.max_value = 5
		wall_thickness_slider.value_changed.connect(_on_wall_thickness_changed)
		_update_slider_label(wall_thickness_slider, wall_thickness_value)

func _get_global_param(param_name: String, default_value):
	if Global and param_name in Global:
		return Global[param_name]
	return default_value

func _load_saved_values():
	# BSP параметры
	if min_room_size_slider:
		min_room_size_slider.value = _get_global_param("bsp_min_room_size", 10)
		_update_slider_label(min_room_size_slider, min_room_size_value)
	
	if max_room_size_slider:
		max_room_size_slider.value = _get_global_param("bsp_max_room_size", 20)
		_update_slider_label(max_room_size_slider, max_room_size_value)
	
	if max_split_iterations_slider:
		max_split_iterations_slider.value = _get_global_param("bsp_max_split_iterations", 10)
		_update_slider_label(max_split_iterations_slider, max_split_iterations_value)
	
	if corridor_thickness_slider:
		corridor_thickness_slider.value = _get_global_param("bsp_corridor_thickness", 3)
		_update_slider_label(corridor_thickness_slider, corridor_thickness_value)
	
	if corridor_variation_slider:
		corridor_variation_slider.value = _get_global_param("bsp_corridor_variation", 8)
		_update_slider_label(corridor_variation_slider, corridor_variation_value)
	
	if corridor_jitter_slider:
		corridor_jitter_slider.value = _get_global_param("bsp_corridor_jitter", 0.7)
		_update_slider_label_float(corridor_jitter_slider, corridor_jitter_value)
	
	if add_mid_points_checkbox:
		add_mid_points_checkbox.button_pressed = _get_global_param("bsp_add_mid_points", true)
	
	# Cellular Automata параметры
	if cellular_fill_probability_slider:
		cellular_fill_probability_slider.value = _get_global_param("cellular_fill_probability", 0.45)
		_update_slider_label_percent(cellular_fill_probability_slider, cellular_fill_probability_value)
	
	if cellular_iterations_slider:
		cellular_iterations_slider.value = _get_global_param("cellular_iterations", 4)
		_update_slider_label(cellular_iterations_slider, cellular_iterations_value)
	
	if cellular_birth_limit_slider:
		cellular_birth_limit_slider.value = _get_global_param("cellular_birth_limit", 4)
		_update_slider_label(cellular_birth_limit_slider, cellular_birth_limit_value)
	
	if cellular_death_limit_slider:
		cellular_death_limit_slider.value = _get_global_param("cellular_death_limit", 4)
		_update_slider_label(cellular_death_limit_slider, cellular_death_limit_value)
	
	# Hybrid параметры
	if hybrid_min_room_size_slider:
		hybrid_min_room_size_slider.value = _get_global_param("hybrid_min_room_size", 10)
		_update_slider_label(hybrid_min_room_size_slider, hybrid_min_room_size_value)
	
	if hybrid_max_room_size_slider:
		hybrid_max_room_size_slider.value = _get_global_param("hybrid_max_room_size", 15)
		_update_slider_label(hybrid_max_room_size_slider, hybrid_max_room_size_value)
	
	if hybrid_cellular_noise_slider:
		hybrid_cellular_noise_slider.value = _get_global_param("hybrid_cellular_noise", 0.5)
		_update_slider_label_float(hybrid_cellular_noise_slider, hybrid_cellular_noise_value)
	
	# Общие параметры
	if width_slider:
		width_slider.value = _get_global_param("map_width", 60)
		_update_slider_label(width_slider, width_value)
	
	if height_slider:
		height_slider.value = _get_global_param("map_height", 60)
		_update_slider_label(height_slider, height_value)
	
	if wall_thickness_slider:
		wall_thickness_slider.value = _get_global_param("wall_thickness", 4)
		_update_slider_label(wall_thickness_slider, wall_thickness_value)

func _update_slider_label(slider: HSlider, label: Label):
	if label and slider:
		label.text = str(int(slider.value))

func _update_slider_label_float(slider: HSlider, label: Label):
	if label and slider:
		label.text = str(round(slider.value * 100) / 100)

func _update_slider_label_percent(slider: HSlider, label: Label):
	if label and slider:
		label.text = str(int(slider.value * 100)) + "%"

# Обработчики BSP параметров
func _on_min_room_size_changed(value: float):
	_update_slider_label(min_room_size_slider, min_room_size_value)

func _on_max_room_size_changed(value: float):
	_update_slider_label(max_room_size_slider, max_room_size_value)

func _on_max_split_iterations_changed(value: float):
	_update_slider_label(max_split_iterations_slider, max_split_iterations_value)

func _on_corridor_thickness_changed(value: float):
	_update_slider_label(corridor_thickness_slider, corridor_thickness_value)

func _on_corridor_variation_changed(value: float):
	_update_slider_label(corridor_variation_slider, corridor_variation_value)

func _on_corridor_jitter_changed(value: float):
	_update_slider_label_float(corridor_jitter_slider, corridor_jitter_value)

# Обработчики Cellular Automata параметров
func _on_cellular_fill_probability_changed(value: float):
	_update_slider_label_percent(cellular_fill_probability_slider, cellular_fill_probability_value)

func _on_cellular_iterations_changed(value: float):
	_update_slider_label(cellular_iterations_slider, cellular_iterations_value)

func _on_cellular_birth_limit_changed(value: float):
	_update_slider_label(cellular_birth_limit_slider, cellular_birth_limit_value)

func _on_cellular_death_limit_changed(value: float):
	_update_slider_label(cellular_death_limit_slider, cellular_death_limit_value)

# Обработчики Hybrid параметров
func _on_hybrid_min_room_size_changed(value: float):
	_update_slider_label(hybrid_min_room_size_slider, hybrid_min_room_size_value)

func _on_hybrid_max_room_size_changed(value: float):
	_update_slider_label(hybrid_max_room_size_slider, hybrid_max_room_size_value)

func _on_hybrid_cellular_noise_changed(value: float):
	_update_slider_label_float(hybrid_cellular_noise_slider, hybrid_cellular_noise_value)

# Обработчики общих параметров
func _on_width_changed(value: float):
	_update_slider_label(width_slider, width_value)

func _on_height_changed(value: float):
	_update_slider_label(height_slider, height_value)

func _on_wall_thickness_changed(value: float):
	_update_slider_label(wall_thickness_slider, wall_thickness_value)

func _on_save_pressed():
	if tab_container:
		Global.selected_algorithm = tab_container.current_tab
		print("Сохранён алгоритм: ", Global.selected_algorithm)
	
	# Сохраняем BSP параметры в Global
	Global.bsp_min_room_size = int(min_room_size_slider.value) if min_room_size_slider else 10
	Global.bsp_max_room_size = int(max_room_size_slider.value) if max_room_size_slider else 20
	Global.bsp_max_split_iterations = int(max_split_iterations_slider.value) if max_split_iterations_slider else 10
	Global.bsp_corridor_thickness = int(corridor_thickness_slider.value) if corridor_thickness_slider else 3
	Global.bsp_corridor_variation = int(corridor_variation_slider.value) if corridor_variation_slider else 8
	Global.bsp_corridor_jitter = corridor_jitter_slider.value if corridor_jitter_slider else 0.7
	Global.bsp_add_mid_points = add_mid_points_checkbox.button_pressed if add_mid_points_checkbox else true
	
	# Сохраняем Cellular Automata параметры в Global
	Global.cellular_fill_probability = cellular_fill_probability_slider.value if cellular_fill_probability_slider else 0.45
	Global.cellular_iterations = int(cellular_iterations_slider.value) if cellular_iterations_slider else 4
	Global.cellular_birth_limit = int(cellular_birth_limit_slider.value) if cellular_birth_limit_slider else 4
	Global.cellular_death_limit = int(cellular_death_limit_slider.value) if cellular_death_limit_slider else 4
	
	# Сохраняем Hybrid параметры в Global
	Global.hybrid_min_room_size = int(hybrid_min_room_size_slider.value) if hybrid_min_room_size_slider else 10
	Global.hybrid_max_room_size = int(hybrid_max_room_size_slider.value) if hybrid_max_room_size_slider else 15
	Global.hybrid_cellular_noise = hybrid_cellular_noise_slider.value if hybrid_cellular_noise_slider else 0.5
	
	# Сохраняем общие параметры в Global
	Global.map_width = int(width_slider.value) if width_slider else 60
	Global.map_height = int(height_slider.value) if height_slider else 60
	Global.wall_thickness = int(wall_thickness_slider.value) if wall_thickness_slider else 4
	
	print("Параметры сохранены")
	
	if save_button:
		save_button.text = "Сохранено"
		save_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		save_button.text = save_button_original_text
		save_button.disabled = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
