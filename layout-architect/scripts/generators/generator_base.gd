extends Node
class_name LevelGenerator

# Параметры генерации
@export var width: int = 50
@export var height: int = 50
@export var wall_thickness: int = 2

# Ссылка на TileMapLayer (будет установлена извне)
var tile_map: TileMapLayer

# Виртуальный метод — переопределяется в наследниках
func generate() -> Array:
	push_error("Метод generate() должен быть переопределен в наследнике!")
	return []

# Универсальная отрисовка комнаты/пещеры по массиву клеток пола
func build_room(floor_cells: Array[Vector2i]) -> void:
	if not tile_map:
		push_error("TileMapLayer не установлен!")
		return
	
	if not _check_minimum_size(floor_cells):
		push_warning("Комната слишком маленькая (мин. ширина 2, высота 2)")
		return
	
	tile_map.clear()
	
	# 1. Заливка пола
	tile_map.set_cells_terrain_connect(floor_cells, 0, 0, true)
	
	# 2. Генерация стен вокруг пола
	var wall_cells: Array[Vector2i] = _generate_walls_around_floor(floor_cells)
	
	# 3. Заливка стен
	if wall_cells.size() > 0:
		tile_map.set_cells_terrain_connect(wall_cells, 1, 0, true)
	
	# 4. Добавление фундамента под стенами (ТВОЯ ВЕРСИЯ!)
	_add_foundation_below_walls(wall_cells)
	
	tile_map.notify_runtime_tile_data_update()

# Проверка минимальных размеров пола
func _check_minimum_size(floor_cells: Array[Vector2i]) -> bool:
	if floor_cells.is_empty():
		return false
	
	var min_x = floor_cells[0].x
	var max_x = floor_cells[0].x
	var min_y = floor_cells[0].y
	var max_y = floor_cells[0].y
	
	for cell in floor_cells:
		min_x = min(min_x, cell.x)
		max_x = max(max_x, cell.x)
		min_y = min(min_y, cell.y)
		max_y = max(max_y, cell.y)
	
	var floor_width = max_x - min_x + 1
	var floor_height = max_y - min_y + 1
	
	return floor_width >= 3 and floor_height >= 3

# Генерация стен вокруг пола с заданной толщиной
func _generate_walls_around_floor(floor_cells: Array[Vector2i]) -> Array[Vector2i]:
	var wall_cells: Array[Vector2i] = []
	var current_layer = floor_cells.duplicate()
	
	for layer in range(wall_thickness):
		var new_layer: Array[Vector2i] = []
		
		for cell in current_layer:
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var neighbor = cell + dir
				if not floor_cells.has(neighbor) and not wall_cells.has(neighbor):
					if not new_layer.has(neighbor):
						new_layer.append(neighbor)
		
		wall_cells.append_array(new_layer)
		current_layer = new_layer
	
	return wall_cells

# 🔥 ТВОЯ ОРИГИНАЛЬНАЯ ФУНКЦИЯ ФУНДАМЕНТА! 🔥
func _add_foundation_below_walls(wall_cells: Array) -> void:
	var to_replace = []
	
	for cell in wall_cells:
		var below = Vector2i(cell.x, cell.y + 1)
		var tile_below = tile_map.get_cell_tile_data(below)
		
		var is_wall_below = false
		if tile_below:
			var src = tile_map.get_cell_source_id(below)
			# Твоя проверка: src == 0 и terrain_set == 1, terrain == 0
			is_wall_below = (src == 0 and tile_below.terrain_set == 1 and tile_below.terrain == 0)
		
		if not is_wall_below:
			to_replace.append(cell)
	
	for cell in to_replace:
		tile_map.set_cell(cell, -1)
		tile_map.set_cells_terrain_connect([cell], 1, 1, 0)

# Очистка карты
func clear() -> void:
	if tile_map:
		tile_map.clear()
