extends LevelGenerator
class_name CellularGenerator

@export var fill_probability: float = 0.45
@export var iterations: int = 4
@export var birth_limit: int = 4
@export var death_limit: int = 3

func generate() -> Array:
	# 1. Инициализация случайной карты
	var wall_map: Array[Array] = []
	for x in range(width):
		wall_map.append([])
		for y in range(height):
			wall_map[x].append(randf() < fill_probability)
	
	# 2. Итерации сглаживания
	for _i in range(iterations):
		wall_map = _smooth(wall_map)
	
	# 3. Преобразуем в массив клеток пола
	var floor_cells: Array[Vector2i] = []
	for x in range(width):
		for y in range(height):
			if not wall_map[x][y]:
				floor_cells.append(Vector2i(x, y))
	
	# 4. Удаляем островки меньше 3x3 (минимум 9 клеток)
	floor_cells = _remove_small_islands(floor_cells)
	
	return floor_cells

func _smooth(wall_map: Array[Array]) -> Array[Array]:
	var new_map: Array[Array] = []
	
	for x in range(width):
		new_map.append([])
		for y in range(height):
			var neighbors = _count_wall_neighbors(wall_map, x, y)
			
			if wall_map[x][y]:
				new_map[x].append(neighbors >= death_limit)
			else:
				new_map[x].append(neighbors >= birth_limit)
	
	return new_map

func _count_wall_neighbors(wall_map: Array[Array], x: int, y: int) -> int:
	var count = 0
	
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i == 0 and j == 0:
				continue
			
			var nx = x + i
			var ny = y + j
			
			if nx < 0 or nx >= width or ny < 0 or ny >= height:
				count += 1
			elif wall_map[nx][ny]:
				count += 1
	
	return count

# Умное удаление маленьких островков (оставляем только компоненты >= 9 клеток)
func _remove_small_islands(floor_cells: Array[Vector2i]) -> Array[Vector2i]:
	if floor_cells.is_empty():
		return []
	
	var visited: Dictionary = {}
	var result: Array[Vector2i] = []
	
	for cell in floor_cells:
		var key = _cell_to_key(cell)
		if not visited.has(key):
			var island = _flood_fill(cell, floor_cells, visited)
			if island.size() >= 9:  # Минимум 3x3 = 9 клеток
				result.append_array(island)
	
	return result

func _flood_fill(start: Vector2i, cells: Array, visited: Dictionary) -> Array:
	var queue: Array = [start]
	var island: Array = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var key = _cell_to_key(current)
		
		if visited.has(key):
			continue
		
		visited[key] = true
		island.append(current)
		
		for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor = current + dir
			if cells.has(neighbor):
				queue.append(neighbor)
	
	return island

func _cell_to_key(cell: Vector2i) -> String:
	return str(cell.x) + "," + str(cell.y)
