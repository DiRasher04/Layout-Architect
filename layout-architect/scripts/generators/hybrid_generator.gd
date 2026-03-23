extends LevelGenerator
class_name HybridGenerator

@export var min_room_size: int = 3  # ← минимум 3×3!
@export var max_room_size: int = 12
@export var cellular_noise: float = 0.2

var bsp = BSPGenerator.new()
var cellular = CellularGenerator.new()

func generate() -> Array:
	# Передаем параметры в BSP генератор
	bsp.width = width
	bsp.height = height
	bsp.min_room_size = min_room_size
	bsp.max_room_size = max_room_size
	
	# Передаем параметры в клеточный генератор
	cellular.width = width
	cellular.height = height
	
	# 1. Генерируем BSP структуру (комнаты + коридоры)
	var bsp_floor = bsp.generate()
	
	# 2. Применяем клеточный шум к краям комнат
	var final_floor: Array[Vector2i] = []
	
	for cell in bsp_floor:
		final_floor.append(cell)
		# Добавляем случайные "выступы" по краям
		if randf() < cellular_noise:
			for dir in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var neighbor = cell + dir
				if not bsp_floor.has(neighbor) and randf() < 0.3:
					final_floor.append(neighbor)
	
	return final_floor
