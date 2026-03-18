
extends TileMapLayer

@export var room_width: int = 20
@export var room_height: int = 10
@export var wall_thickness: int = 3

func _ready():
	generate_room_with_foundation()

func generate_room_with_foundation():
	clear()
	
	var floor_cells = []
	for x in range(room_width):
		for y in range(room_height):
			floor_cells.append(Vector2i(x, y))
	
	for cell in floor_cells:
		set_cell(cell, -1)
	set_cells_terrain_connect(floor_cells, 0, 0, 0)
	
	var wall_cells = []
	
	for x in range(-wall_thickness, room_width + wall_thickness):
		for w in range(wall_thickness):
			wall_cells.append(Vector2i(x, -wall_thickness + w))
	
	for x in range(-wall_thickness, room_width + wall_thickness):
		for w in range(wall_thickness):
			wall_cells.append(Vector2i(x, room_height + w))
	
	for y in range(room_height):
		for w in range(wall_thickness):
			wall_cells.append(Vector2i(-wall_thickness + w, y))
	
	for y in range(room_height):
		for w in range(wall_thickness):
			wall_cells.append(Vector2i(room_width + w, y))
	
	for cell in wall_cells:
		set_cell(cell, -1)
	set_cells_terrain_connect(wall_cells, 1, 0, 0)
	
	add_foundation_below_walls(wall_cells)
	
	notify_runtime_tile_data_update()

func add_foundation_below_walls(wall_cells: Array):
	var to_replace = []
	
	for cell in wall_cells:
		var below = Vector2i(cell.x, cell.y + 1)
		var tile_below = get_cell_tile_data(below)
		
		var is_wall_below = false
		if tile_below:
			var src = get_cell_source_id(below)
			is_wall_below = (src == 0 and tile_below.terrain_set == 1 and tile_below.terrain == 0)
		
		if not is_wall_below:
			to_replace.append(cell)
	
	for cell in to_replace:
		set_cell(cell, -1)
		set_cells_terrain_connect([cell], 1, 1, 0)
		
		
