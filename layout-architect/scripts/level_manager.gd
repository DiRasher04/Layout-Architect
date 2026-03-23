extends Node2D  # ← теперь висит на корневом узле

@export var generator_type: String = "hybrid"
#bsp, cellular, hybrid
@export var width: int = 80
@export var height: int = 60
@export var wall_thickness: int = 2

# Ссылка на TileMapLayer (нужно будет перетащить в инспекторе)
@export var tile_map_layer: TileMapLayer

var generator: LevelGenerator

func _ready():
	_generate_level()

func _generate_level():
	if not tile_map_layer:
		push_error("TileMapLayer не назначен! Перетащите его в поле tile_map_layer")
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
	generator.tile_map = tile_map_layer  # ← используем ссылку
	
	var floor_cells = generator.generate()
	
	if floor_cells.size() > 0:
		generator.build_room(floor_cells)
	else:
		push_error("Генерация не дала результатов!")
