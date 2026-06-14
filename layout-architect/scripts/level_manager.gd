extends Node2D

@export var tile_map_layer: TileMapLayer

@export var enemy_spawn_chance: float = 0.01
@export var heart_spawn_chance: float = 0.01
@export var max_enemies: int = 20
@export var max_hearts: int = 10

@export var enemy_scene: PackedScene
@export var heart_scene: PackedScene

@export var debug_spawn: bool = true

var generator: LevelGenerator
var spawned_enemies: Array = []
var spawned_hearts: Array = []

@onready var algorithm_label: Label = $AlgorithmLabel

var generator_type: String = "bsp"
var last_generation_time: int = 0

var current_width: int = 60
var current_height: int = 60
var current_wall_thickness: int = 4

var is_generating: bool = false
var _initialized: bool = false

func _ready():
	if _initialized:
		print("⚠️ _ready() уже был вызван, пропускаем повторную инициализацию")
		return
	_initialized = true
	
	print("========== level_manager._ready() ==========")
	_load_algorithm_from_global()
	_load_map_parameters_from_global()
	_update_algorithm_display()
	_generate_level()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		_return_to_main_menu()

func _return_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _load_algorithm_from_global():
	if not Global:
		generator_type = "bsp"
		return
	
	var alg_index = Global.selected_algorithm if "selected_algorithm" in Global else 0
	match alg_index:
		0:
			generator_type = "bsp"
		1:
			generator_type = "cellular"
		2:
			generator_type = "hybrid"
		_:
			generator_type = "bsp"

func _load_map_parameters_from_global():
	if not Global:
		return
	
	current_width = Global.map_width if "map_width" in Global else 60
	current_height = Global.map_height if "map_height" in Global else 60
	current_wall_thickness = Global.wall_thickness if "wall_thickness" in Global else 4

func _update_algorithm_display() -> void:
	if not algorithm_label:
		return
	
	match generator_type.to_lower():
		"bsp":
			algorithm_label.text = "ТЕКУЩИЙ АЛГОРИТМ: BSP"
			algorithm_label.modulate = Color(1, 0.5, 0.5)
		"cellular":
			algorithm_label.text = "ТЕКУЩИЙ АЛГОРИТМ: CELLULAR AUTOMATA"
			algorithm_label.modulate = Color(0.5, 0.7, 1)
		"hybrid":
			algorithm_label.text = "ТЕКУЩИЙ АЛГОРИТМ: HYBRID"
			algorithm_label.modulate = Color(0.5, 1, 0.5)

func _get_global_param(param_name: String, default_value):
	if Global and param_name in Global:
		return Global[param_name]
	return default_value

func _generate_level():
	if not tile_map_layer:
		print("⚠️ Пропускаем генерацию: tile_map_layer не назначен")
		return
	print("Вызов _generate_level() из: ", get_stack())
	if is_generating:
		print("⚠️ Генерация уже запущена, пропускаем повторный вызов")
		return
	is_generating = true
	
	print("========== level_manager._generate_level() ==========")
	print("tile_map_layer = ", tile_map_layer)
	print("enemy_scene = ", enemy_scene)
	print("heart_scene = ", heart_scene)
	print("current_width = ", current_width)
	print("current_height = ", current_height)
	print("current_wall_thickness = ", current_wall_thickness)
	print("generator_type = ", generator_type)
	print("=====================================================")
	
	if not tile_map_layer:
		push_error("TileMapLayer не назначен!")
		is_generating = false
		return
	
	_load_map_parameters_from_global()
	
	var start_time = Time.get_ticks_msec()
	
	match generator_type.to_lower():
		"cellular":
			generator = CellularGenerator.new()
			generator.fill_probability = _get_global_param("cellular_fill_probability", 0.45)
			generator.iterations = _get_global_param("cellular_iterations", 4)
			generator.birth_limit = _get_global_param("cellular_birth_limit", 4)
			generator.death_limit = _get_global_param("cellular_death_limit", 4)
		"bsp":
			generator = BSPGenerator.new()
			generator.min_room_size = _get_global_param("bsp_min_room_size", 10)
			generator.max_room_size = _get_global_param("bsp_max_room_size", 20)
			generator.max_split_iterations = _get_global_param("bsp_max_split_iterations", 10)
			generator.corridor_thickness = _get_global_param("bsp_corridor_thickness", 3)
			generator.corridor_variation = _get_global_param("bsp_corridor_variation", 8)
			generator.corridor_jitter = _get_global_param("bsp_corridor_jitter", 0.7)
			generator.add_mid_points = _get_global_param("bsp_add_mid_points", true)
		"hybrid":
			generator = HybridGenerator.new()
			generator.min_room_size = _get_global_param("hybrid_min_room_size", 10)
			generator.max_room_size = _get_global_param("hybrid_max_room_size", 15)
			generator.cellular_noise = _get_global_param("hybrid_cellular_noise", 0.5)
		_:
			generator = CellularGenerator.new()
	
	generator.width = current_width
	generator.height = current_height
	generator.wall_thickness = current_wall_thickness
	generator.tile_map = tile_map_layer
	
	var floor_cells = generator.generate()
	
	if floor_cells.size() > 0:
		generator.build_room(floor_cells)
		await get_tree().process_frame
		
		last_generation_time = Time.get_ticks_msec() - start_time
		print("Время генерации: ", last_generation_time, " мс")
		
		if debug_spawn:
			_analyze_all_tiles()
		
		_spawn_entities_on_actual_floor()
	else:
		push_error("Генерация не дала результатов!")
	
	is_generating = false

func _analyze_all_tiles() -> void:
	print("\n========== АНАЛИЗ ВСЕХ ТАЙЛОВ ==========")
	
	var terrain_set_counts = {}
	var terrain_counts = {}
	var total_cells = 0
	
	for x in range(current_width):
		for y in range(current_height):
			var cell = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(cell)
			
			if not tile_data:
				continue
			
			total_cells += 1
			var ts = tile_data.terrain_set
			var t = tile_data.terrain
			
			terrain_set_counts[ts] = terrain_set_counts.get(ts, 0) + 1
			terrain_counts[str(ts) + "," + str(t)] = terrain_counts.get(str(ts) + "," + str(t), 0) + 1
	
	print("Всего клеток с тайлами: ", total_cells)
	print("Terrain Set распределение:")
	for ts in terrain_set_counts:
		print("  Set ", ts, ": ", terrain_set_counts[ts], " клеток")
	
	print("Terrain распределение:")
	for key in terrain_counts:
		print("  Set ", key, ": ", terrain_counts[key], " клеток")
	
	print("==========================================\n")

func _spawn_entities_on_actual_floor() -> void:
	if not enemy_scene or not heart_scene:
		push_warning("Не назначены сцены для спавна!")
		return
	
	_clear_entities()
	
	var actual_floor_cells: Array[Vector2i] = []
	
	for x in range(current_width):
		for y in range(current_height):
			var cell = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(cell)
			
			if tile_data and tile_data.terrain_set == 0 and tile_data.terrain == 0:
				actual_floor_cells.append(cell)
	
	if debug_spawn:
		print("\n========== АНАЛИЗ РЕАЛЬНОГО ПОЛА ==========")
		print("Всего клеток с полом: ", actual_floor_cells.size())
		print("==========================================\n")
	
	if actual_floor_cells.is_empty():
		print("НЕТ клеток пола для спавна!")
		return
	
	var enemy_count = 0
	var heart_count = 0
	var max_attempts = 500
	
	if debug_spawn:
		print("========== НАЧАЛО СПАВНА ==========")
	
	for i in range(max_enemies):
		if enemy_count >= max_enemies:
			break
		
		var attempts = 0
		while attempts < max_attempts:
			var random_cell = actual_floor_cells[randi() % actual_floor_cells.size()]
			var world_pos = tile_map_layer.map_to_local(random_cell)
			
			var cell_already_has_enemy = false
			for enemy in spawned_enemies:
				if is_instance_valid(enemy):
					var enemy_cell = tile_map_layer.local_to_map(enemy.global_position)
					if enemy_cell == random_cell:
						cell_already_has_enemy = true
						break
			
			if not cell_already_has_enemy:
				_spawn_entity(enemy_scene, world_pos, "enemy", random_cell)
				enemy_count += 1
				break
			
			attempts += 1
	
	for i in range(max_hearts):
		if heart_count >= max_hearts:
			break
		
		var attempts = 0
		while attempts < max_attempts:
			var random_cell = actual_floor_cells[randi() % actual_floor_cells.size()]
			var world_pos = tile_map_layer.map_to_local(random_cell)
			
			var cell_already_has_entity = false
			for enemy in spawned_enemies:
				if is_instance_valid(enemy):
					var enemy_cell = tile_map_layer.local_to_map(enemy.global_position)
					if enemy_cell == random_cell:
						cell_already_has_entity = true
						break
			for heart in spawned_hearts:
				if is_instance_valid(heart):
					var heart_cell = tile_map_layer.local_to_map(heart.global_position)
					if heart_cell == random_cell:
						cell_already_has_entity = true
						break
			
			if not cell_already_has_entity:
				_spawn_entity(heart_scene, world_pos, "heart", random_cell)
				heart_count += 1
				break
			
			attempts += 1
	
	if debug_spawn:
		print("========== ИТОГИ СПАВНА ==========")
		print("Врагов: ", enemy_count, "/", max_enemies, ", сердечек: ", heart_count, "/", max_hearts)
		print("==================================\n")

func _spawn_entity(scene: PackedScene, position: Vector2, type: String, cell: Vector2i) -> void:
	var instance = scene.instantiate()
	instance.global_position = position
	add_child(instance)
	
	if debug_spawn:
		print("Спавн ", type, " на клетке ", cell)
	
	match type:
		"enemy":
			spawned_enemies.append(instance)
		"heart":
			spawned_hearts.append(instance)

func _clear_entities() -> void:
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	
	for heart in spawned_hearts:
		if is_instance_valid(heart):
			heart.queue_free()
	spawned_hearts.clear()
