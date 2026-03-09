extends Node2D

@onready var floor_layer = $TileMapLayer_Floor
@onready var walls_layer = $TileMapLayer_Walls

func _ready():
	generate()

func generate():
	# Работаем с floor_layer
	for x in 10:
		floor_layer.set_cell(Vector2i(x, 5), 0, Vector2i(0, 0))
	
	floor_layer.notify_runtime_tile_data_update()
