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

var save_button_original_text: String = ""

func _ready():
	if save_button:
		save_button_original_text = save_button.text
		save_button.pressed.connect(_on_save_pressed)
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	_setup_bsp_sliders()
	_load_saved_values()

func _setup_bsp_sliders():
	if min_room_size_slider and min_room_size_value:
		min_room_size_slider.min_value = 3
		min_room_size_slider.max_value = 15
		min_room_size_slider.value_changed.connect(_on_min_room_size_changed)
	
	if max_room_size_slider and max_room_size_value:
		max_room_size_slider.min_value = 5
		max_room_size_slider.max_value = 30
		max_room_size_slider.value_changed.connect(_on_max_room_size_changed)
	
	if max_split_iterations_slider and max_split_iterations_value:
		max_split_iterations_slider.min_value = 1
		max_split_iterations_slider.max_value = 12
		max_split_iterations_slider.value_changed.connect(_on_max_split_iterations_changed)
	
	if corridor_thickness_slider and corridor_thickness_value:
		corridor_thickness_slider.min_value = 1
		corridor_thickness_slider.max_value = 5
		corridor_thickness_slider.value_changed.connect(_on_corridor_thickness_changed)
	
	if corridor_variation_slider and corridor_variation_value:
		corridor_variation_slider.min_value = 0
		corridor_variation_slider.max_value = 15
		corridor_variation_slider.value_changed.connect(_on_corridor_variation_changed)
	
	if corridor_jitter_slider and corridor_jitter_value:
		corridor_jitter_slider.min_value = 0.0
		corridor_jitter_slider.max_value = 1.0
		corridor_jitter_slider.step = 0.01
		corridor_jitter_slider.value_changed.connect(_on_corridor_jitter_changed)

func _load_saved_values():
	if min_room_size_slider:
		if "bsp_min_room_size" in Global:
			min_room_size_slider.value = Global.bsp_min_room_size
		else:
			min_room_size_slider.value = 10
		_update_slider_label(min_room_size_slider, min_room_size_value)
	
	if max_room_size_slider:
		if "bsp_max_room_size" in Global:
			max_room_size_slider.value = Global.bsp_max_room_size
		else:
			max_room_size_slider.value = 20
		_update_slider_label(max_room_size_slider, max_room_size_value)
	
	if max_split_iterations_slider:
		if "bsp_max_split_iterations" in Global:
			max_split_iterations_slider.value = Global.bsp_max_split_iterations
		else:
			max_split_iterations_slider.value = 10
		_update_slider_label(max_split_iterations_slider, max_split_iterations_value)
	
	if corridor_thickness_slider:
		if "bsp_corridor_thickness" in Global:
			corridor_thickness_slider.value = Global.bsp_corridor_thickness
		else:
			corridor_thickness_slider.value = 3
		_update_slider_label(corridor_thickness_slider, corridor_thickness_value)
	
	if corridor_variation_slider:
		if "bsp_corridor_variation" in Global:
			corridor_variation_slider.value = Global.bsp_corridor_variation
		else:
			corridor_variation_slider.value = 8
		_update_slider_label(corridor_variation_slider, corridor_variation_value)
	
	if corridor_jitter_slider:
		if "bsp_corridor_jitter" in Global:
			corridor_jitter_slider.value = Global.bsp_corridor_jitter
		else:
			corridor_jitter_slider.value = 0.7
		_update_slider_label_float(corridor_jitter_slider, corridor_jitter_value)
	
	if add_mid_points_checkbox:
		if "bsp_add_mid_points" in Global:
			add_mid_points_checkbox.button_pressed = Global.bsp_add_mid_points
		else:
			add_mid_points_checkbox.button_pressed = true

func _update_slider_label(slider: HSlider, label: Label):
	if label:
		label.text = str(int(slider.value))

func _update_slider_label_float(slider: HSlider, label: Label):
	if label:
		label.text = str(round(slider.value * 100) / 100)

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
	
	print("Параметры BSP сохранены")
	
	if save_button:
		save_button.text = "Сохранено"
		save_button.disabled = true
		await get_tree().create_timer(1.0).timeout
		save_button.text = save_button_original_text
		save_button.disabled = false

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
