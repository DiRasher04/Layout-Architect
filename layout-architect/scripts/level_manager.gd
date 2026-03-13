extends Node

# Ссылка на TileMap в твоей сцене
@export var tile_map: TileMapLayer

# Какой алгоритм используем
@export var algorithm: String = "cellular"  # "cellular", "bsp", "hybrid"

func _ready():
	# Вызываем генерацию при старте сцены
	generate_new_level()
	
func _on_generate_button_pressed():
	# Перегенерировать уровень
	$LevelManager.generate_new_level()

func generate_new_level():
	var generator: GeneratorBase
	var map_data
	
	# Создаем нужный генератор
	match algorithm:
		"cellular":
			generator = CellularGenerator.new()
		"bsp":
			generator = BSPGenerator.new()
		"hybrid":
			generator = HybridGenerator.new()
	
	# Настраиваем генератор
	generator.width = 50
	generator.height = 50
	generator.tile_map = tile_map  # Передаем ссылку на TileMap
	
	# Генерируем карту
	map_data = generator.generate()
	
	# Применяем к TileMap
	apply_map_to_tilemap(map_data)

func apply_map_to_tilemap(map_data: Array):
	tile_map.clear()
	
	# Проходим по всей карте
	for y in range(map_data.size()):
		for x in range(map_data[y].size()):
			if map_data[y][x] == 0:
				# Ставим пол (настрой source_id под твой TileSet)
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
			else:
				# Ставим стену
				tile_map.set_cell(Vector2i(x, y), 1, Vector2i(0, 0))
