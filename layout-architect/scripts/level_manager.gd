extends Node2D

@export var generator_type: String = "bsp"
@export var width: int = 60
@export var height: int = 60
@export var wall_thickness: int = 4
@export var tile_map_layer: TileMapLayer

# Параметры спавна
@export var enemy_spawn_chance: float = 0.01
@export var heart_spawn_chance: float = 0.01
@export var max_enemies: int = 20
@export var max_hearts: int = 10

# Сцены для спавна
@export var enemy_scene: PackedScene
@export var heart_scene: PackedScene

# Отладка
@export var debug_spawn: bool = true

var generator: LevelGenerator
var spawned_enemies: Array = []
var spawned_hearts: Array = []

func _ready():
	_generate_level()

func _generate_level():
	if not tile_map_layer:
		push_error("TileMapLayer не назначен!")
		return
	
	match generator_type.to_lower():
		"cellular":
			generator = CellularGenerator.new()
		"bsp":
			generator = BSPGenerator.new()
		"hybrid":
			generator = HybridGenerator.new()
		_:
			generator = CellularGenerator.new()
	
	generator.width = width
	generator.height = height
	generator.wall_thickness = wall_thickness
	generator.tile_map = tile_map_layer
	
	var floor_cells = generator.generate()
	
	if floor_cells.size() > 0:
		generator.build_room(floor_cells)
		await get_tree().process_frame
		
		if debug_spawn:
			_analyze_all_tiles()
		
		# 🔥 НОВОЕ: спавним по РЕАЛЬНОМУ анализу карты, а не по floor_cells!
		_spawn_entities_on_actual_floor()
	else:
		push_error("Генерация не дала результатов!")

# Анализ всех тайлов на карте
func _analyze_all_tiles() -> void:
	print("\n========== АНАЛИЗ ВСЕХ ТАЙЛОВ ==========")
	
	var terrain_set_counts = {}
	var terrain_counts = {}
	var total_cells = 0
	
	for x in range(width):
		for y in range(height):
			var cell = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(cell)
			
			if not tile_data:
				continue
			
			total_cells += 1
			var ts = tile_data.terrain_set
			var t = tile_data.terrain
			
			terrain_set_counts[ts] = terrain_set_counts.get(ts, 0) + 1
			
			var key = str(ts) + "," + str(t)
			terrain_counts[key] = terrain_counts.get(key, 0) + 1
	
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
	
	# Собираем ВСЕ клетки, где реально пол
	var actual_floor_cells: Array[Vector2i] = []
	
	for x in range(width):
		for y in range(height):
			var cell = Vector2i(x, y)
			var tile_data = tile_map_layer.get_cell_tile_data(cell)
			
			if tile_data and tile_data.terrain_set == 0 and tile_data.terrain == 0:
				actual_floor_cells.append(cell)
	
	if debug_spawn:
		print("\n========== АНАЛИЗ РЕАЛЬНОГО ПОЛА НА КАРТЕ ==========")
		print("Всего клеток с полом (Set0, Terrain0): ", actual_floor_cells.size())
		print("====================================================\n")
	
	if actual_floor_cells.is_empty():
		print("⚠️ НЕТ клеток пола на карте для спавна!")
		return
	
	# 🔥 НЕ перемешиваем весь массив!
	# Вместо этого будем выбирать случайные клетки
	
	var enemy_count = 0
	var heart_count = 0
	var max_attempts = 500  # чтобы не зациклиться
	
	if debug_spawn:
		print("========== НАЧАЛО СПАВНА ==========")
	
	# Спавн врагов — выбираем случайные клетки
	for i in range(max_enemies):
		if enemy_count >= max_enemies:
			break
		
		# Пытаемся найти свободную клетку для врага
		var attempts = 0
		while attempts < max_attempts:
			var random_cell = actual_floor_cells[randi() % actual_floor_cells.size()]
			var world_pos = tile_map_layer.map_to_local(random_cell)
			
			# Проверяем, что на этой клетке еще нет врага
			var cell_already_has_enemy = false
			for enemy in spawned_enemies:
				var enemy_cell = tile_map_layer.local_to_map(enemy.global_position)
				if enemy_cell == random_cell:
					cell_already_has_enemy = true
					break
			
			if not cell_already_has_enemy:
				_spawn_entity(enemy_scene, world_pos, "enemy", random_cell)
				enemy_count += 1
				break
			
			attempts += 1
	
	# Спавн сердечек — выбираем случайные клетки
	for i in range(max_hearts):
		if heart_count >= max_hearts:
			break
		
		var attempts = 0
		while attempts < max_attempts:
			var random_cell = actual_floor_cells[randi() % actual_floor_cells.size()]
			var world_pos = tile_map_layer.map_to_local(random_cell)
			
			# Проверяем, что на этой клетке нет врага и нет сердечка
			var cell_already_has_entity = false
			for enemy in spawned_enemies:
				var enemy_cell = tile_map_layer.local_to_map(enemy.global_position)
				if enemy_cell == random_cell:
					cell_already_has_entity = true
					break
			for heart in spawned_hearts:
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
		print("Спавнено: врагов - ", enemy_count, "/", max_enemies, ", сердечек - ", heart_count, "/", max_hearts)
		print("==================================\n")

func _spawn_entity(scene: PackedScene, position: Vector2, type: String, cell: Vector2i) -> void:
	var instance = scene.instantiate()
	instance.global_position = position
	add_child(instance)
	
	if debug_spawn:
		print("🔥 Спавн ", type, " на клетке ", cell)
		var tile_data = tile_map_layer.get_cell_tile_data(cell)
		if tile_data:
			print("  📍 На клетке ", cell, " terrain_set=", tile_data.terrain_set, " terrain=", tile_data.terrain)
	
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
