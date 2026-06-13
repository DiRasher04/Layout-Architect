extends CanvasLayer

# Ссылки на узлы
@onready var panel = $Panel
@onready var algorithm_value = $Panel/algorithm_value
@onready var metrics_value = $Panel/metrics_value
@onready var generation_value = $Panel/generation_value
@onready var time_value = $Panel/time_value
@onready var export_button = $Panel/export_button
@onready var generation_count_spinbox = $Panel/generation_count_spinbox
@onready var close_button = $Panel/close_button

var level_manager: Node2D

func _ready():
	hide()
	export_button.pressed.connect(_on_export_pressed)

func _input(event: InputEvent):
	if event.is_action_pressed("ui_debug"):
		if visible:
			hide()
		else:
			_update_data()
			show()

func _update_data():
	_find_level_manager()
	
	if not level_manager:
		algorithm_value.text = "LevelManager не найден"
		metrics_value.text = "Ошибка"
		generation_value.text = "Ошибка"
		time_value.text = "Ошибка"
		return
	
	# 1. Алгоритм
	var alg_name = ""
	match level_manager.generator_type:
		"bsp":
			alg_name = "BSP (Binary Space Partitioning)"
		"cellular":
			alg_name = "Cellular Automata"
		"hybrid":
			alg_name = "Hybrid (BSP + Cellular)"
		_:
			alg_name = level_manager.generator_type
	algorithm_value.text = alg_name
	
	# 2. Метрики уровня
	var metrics = ""
	metrics += "Ширина карты: " + str(level_manager.width) + "\n"
	metrics += "Высота карты: " + str(level_manager.height) + "\n"
	metrics += "Толщина стен: " + str(level_manager.wall_thickness) + "\n"
	metrics += "Всего клеток: " + str(level_manager.width * level_manager.height) + "\n"
	metrics += "Клеток пола: " + str(_count_floor_tiles()) + "\n"
	metrics += "Клеток стен: " + str(_count_wall_tiles()) + "\n"
	metrics += "Количество комнат: " + str(_count_rooms()) + "\n"
	metrics += "Врагов: " + str(level_manager.spawned_enemies.size()) + "\n"
	metrics += "Сердечек: " + str(level_manager.spawned_hearts.size())
	metrics_value.text = metrics
	
	# 3. Параметры генерации - читаем из level_manager.generator
	var generation = ""
	if level_manager.generator:
		match level_manager.generator_type.to_lower():
			"bsp":
				var gen = level_manager.generator
				generation = "min_room_size: " + str(gen.min_room_size) + "\n"
				generation += "max_room_size: " + str(gen.max_room_size) + "\n"
				generation += "max_split_iterations: " + str(gen.max_split_iterations) + "\n"
				generation += "corridor_thickness: " + str(gen.corridor_thickness) + "\n"
				generation += "corridor_variation: " + str(gen.corridor_variation) + "\n"
				generation += "corridor_jitter: " + str(gen.corridor_jitter) + "\n"
				generation += "add_mid_points: " + ("Да" if gen.add_mid_points else "Нет")
			"cellular":
				var gen = level_manager.generator
				generation = "fill_probability: " + str(gen.fill_probability * 100) + "%\n"
				generation += "iterations: " + str(gen.iterations) + "\n"
				generation += "birth_limit: " + str(gen.birth_limit) + "\n"
				generation += "death_limit: " + str(gen.death_limit)
			"hybrid":
				var gen = level_manager.generator
				generation = "min_room_size: " + str(gen.min_room_size) + "\n"
				generation += "max_room_size: " + str(gen.max_room_size) + "\n"
				generation += "cellular_noise: " + str(gen.cellular_noise)
			_:
				generation = "Неизвестный алгоритм"
	else:
		generation = "Генератор не инициализирован"
	
	generation_value.text = generation
	
	# 4. Время
	var time_str = "Текущее время: " + _get_current_time() + "\n"
	if "last_generation_time" in level_manager:
		time_str += "Время генерации: " + str(level_manager.last_generation_time) + " мс"
	else:
		time_str += "Время генерации: не замерено"
	time_value.text = time_str

func _find_level_manager():
	var root = get_tree().root
	for child in root.get_children():
		if child.has_method("_generate_level"):
			level_manager = child
			break
		for subchild in child.get_children():
			if subchild.has_method("_generate_level"):
				level_manager = subchild
				break

func _count_floor_tiles() -> int:
	if not level_manager or not level_manager.tile_map_layer:
		return 0
	
	var count = 0
	for x in range(level_manager.width):
		for y in range(level_manager.height):
			var cell = Vector2i(x, y)
			var tile_data = level_manager.tile_map_layer.get_cell_tile_data(cell)
			if tile_data and tile_data.terrain_set == 0 and tile_data.terrain == 0:
				count += 1
	return count

func _count_wall_tiles() -> int:
	if not level_manager or not level_manager.tile_map_layer:
		return 0
	
	var count = 0
	for x in range(level_manager.width):
		for y in range(level_manager.height):
			var cell = Vector2i(x, y)
			var tile_data = level_manager.tile_map_layer.get_cell_tile_data(cell)
			if tile_data and tile_data.terrain_set == 1 and tile_data.terrain == 0:
				count += 1
	return count

func _count_rooms() -> int:
	if not level_manager or not level_manager.tile_map_layer:
		return 0
	
	var visited = {}
	var room_count = 0
	
	for x in range(level_manager.width):
		for y in range(level_manager.height):
			var cell = Vector2i(x, y)
			var tile_data = level_manager.tile_map_layer.get_cell_tile_data(cell)
			
			if tile_data and tile_data.terrain_set == 0 and tile_data.terrain == 0:
				if not visited.has(str(cell)):
					room_count += 1
					_flood_fill(cell, visited)
	
	return room_count

func _flood_fill(start: Vector2i, visited: Dictionary):
	var queue = [start]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var key = str(current)
		
		if visited.has(key):
			continue
		
		visited[key] = true
		
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor = current + dir
			if neighbor.x >= 0 and neighbor.x < level_manager.width and neighbor.y >= 0 and neighbor.y < level_manager.height:
				var tile_data = level_manager.tile_map_layer.get_cell_tile_data(neighbor)
				if tile_data and tile_data.terrain_set == 0 and tile_data.terrain == 0:
					queue.append(neighbor)

func _get_current_time() -> String:
	var time = Time.get_datetime_dict_from_system()
	return str(time.hour).pad_zeros(2) + ":" + str(time.minute).pad_zeros(2) + ":" + str(time.second).pad_zeros(2)

func _get_timestamp() -> String:
	var time = Time.get_datetime_dict_from_system()
	return str(time.year) + "-" + str(time.month) + "-" + str(time.day) + "_" + str(time.hour) + "-" + str(time.minute) + "-" + str(time.second)

func _on_close_pressed():
	hide()

func _on_export_pressed():
	if not level_manager:
		_find_level_manager()
	
	if not level_manager:
		print("Ошибка: LevelManager не найден")
		return
	
	var count = int(generation_count_spinbox.value)
	if count <= 1:
		_export_single_to_csv()
	else:
		_export_batch_to_csv(count)

func _export_single_to_csv():
	var timestamp = _get_timestamp()
	var suggested_filename = "level_stats_" + timestamp + ".csv"
	
	var dialog = FileDialog.new()
	dialog.title = "Выберите папку для сохранения CSV"
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.current_file = suggested_filename
	dialog.add_filter("*.csv", "CSV Files")
	
	add_child(dialog)
	dialog.popup_centered()
	
	var file_path = await dialog.file_selected
	dialog.queue_free()
	
	if file_path == "" or file_path == null:
		print("Сохранение отменено")
		return
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Ошибка: не удалось создать файл")
		return
	
	var headers = "timestamp,algorithm,width,height,wall_thickness,total_cells,floor_cells,wall_cells,rooms,enemies,hearts,generation_time_ms\n"
	file.store_string(headers)
	
	file.store_string(_get_csv_line())
	file.close()
	
	print("CSV экспортирован: ", file_path)

func _export_batch_to_csv(batch_count: int):
	var timestamp = _get_timestamp()
	var suggested_filename = "batch_stats_" + str(batch_count) + "_" + timestamp + ".csv"
	
	var dialog = FileDialog.new()
	dialog.title = "Выберите папку для сохранения CSV"
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.current_file = suggested_filename
	dialog.add_filter("*.csv", "CSV Files")
	
	add_child(dialog)
	dialog.popup_centered()
	
	var file_path = await dialog.file_selected
	dialog.queue_free()
	
	if file_path == "" or file_path == null:
		print("Сохранение отменено")
		return
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		print("Ошибка: не удалось создать файл")
		return
	
	var headers = "generation_index,timestamp,algorithm,width,height,wall_thickness,total_cells,floor_cells,wall_cells,rooms,enemies,hearts,generation_time_ms\n"
	file.store_string(headers)
	
	export_button.disabled = true
	export_button.text = "Генерация..."
	
	for i in range(batch_count):
		print("Генерация ", i + 1, "/", batch_count)
		
		level_manager._generate_level()
		await get_tree().process_frame
		await get_tree().create_timer(0.05).timeout
		
		var line = str(i + 1) + ","
		line += _get_timestamp() + ","
		line += _get_csv_line()
		file.store_string(line)
	
	file.close()
	
	export_button.disabled = false
	export_button.text = "Экспорт в CSV"
	
	print("Сохранено ", batch_count, " записей в файл: ", file_path)

func _get_csv_line() -> String:
	_update_data()
	
	var line = ""
	line += level_manager.generator_type + ","
	line += str(level_manager.width) + ","
	line += str(level_manager.height) + ","
	line += str(level_manager.wall_thickness) + ","
	line += str(level_manager.width * level_manager.height) + ","
	line += str(_count_floor_tiles()) + ","
	line += str(_count_wall_tiles()) + ","
	line += str(_count_rooms()) + ","
	line += str(level_manager.spawned_enemies.size()) + ","
	line += str(level_manager.spawned_hearts.size()) + ","
	
	var gen_time = level_manager.last_generation_time if "last_generation_time" in level_manager else 0
	line += str(gen_time) + "\n"
	
	return line
