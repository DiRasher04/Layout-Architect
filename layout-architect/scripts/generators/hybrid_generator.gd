class_name GeneratorBase
extends RefCounted

# Размер уровня
var width: int = 50
var height: int = 50

# Ссылка на TileMap (будем передавать)
var tile_map: TileMapLayer

# Виртуальный метод - его будут переопределять наследники
func generate() -> Dictionary:
	# Возвращает карту в виде Dictionary или Array
	return {}

# Применить генерацию к TileMap
func apply_to_tilemap(map_data) -> void:
	if not tile_map:
		print("Нет TileMap!")
		return
	
	# Очищаем старый уровень
	tile_map.clear()
	
	# Здесь будем заполнять клетки
	# Код зависит от формата map_data
