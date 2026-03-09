extends TileMapLayer  # скрипт на самом TileMapLayer

func _ready():
	generate()

func generate():
	# Просто вызываем set_cell без переменных
	for x in range(10):
		for y in range(10):
			set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	notify_runtime_tile_data_update()
