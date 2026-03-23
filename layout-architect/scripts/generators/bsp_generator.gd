extends LevelGenerator
class_name BSPGenerator

@export var min_room_size: int = 3  # ← минимум 3×3!
@export var max_room_size: int = 10
@export var max_split_iterations: int = 8

var floor_cells: Array[Vector2i] = []

func generate() -> Array:
	floor_cells.clear()
	
	var root = _BSPNode.new(Rect2i(0, 0, width, height))
	_split_node(root, max_split_iterations)
	_create_rooms(root)
	_create_corridors(root)
	
	return floor_cells

func _split_node(node, depth: int) -> void:
	# Проверяем, можно ли разделить (нужно место для двух комнат минимум 3×3)
	if depth <= 0 or node.rect.size.x < min_room_size * 2 or node.rect.size.y < min_room_size * 2:
		return
	
	var split_horizontal = randf() < 0.5
	var split_pos: int
	
	if split_horizontal:
		split_pos = randi_range(min_room_size, node.rect.size.x - min_room_size)
		var left_rect = Rect2i(node.rect.position, Vector2i(split_pos, node.rect.size.y))
		var right_rect = Rect2i(node.rect.position + Vector2i(split_pos, 0), Vector2i(node.rect.size.x - split_pos, node.rect.size.y))
		node.left = _BSPNode.new(left_rect)
		node.right = _BSPNode.new(right_rect)
	else:
		split_pos = randi_range(min_room_size, node.rect.size.y - min_room_size)
		var top_rect = Rect2i(node.rect.position, Vector2i(node.rect.size.x, split_pos))
		var bottom_rect = Rect2i(node.rect.position + Vector2i(0, split_pos), Vector2i(node.rect.size.x, node.rect.size.y - split_pos))
		node.left = _BSPNode.new(top_rect)
		node.right = _BSPNode.new(bottom_rect)
	
	_split_node(node.left, depth - 1)
	_split_node(node.right, depth - 1)

func _create_rooms(node) -> void:
	if node.left or node.right:
		if node.left:
			_create_rooms(node.left)
		if node.right:
			_create_rooms(node.right)
	else:
		# Лист — создаем комнату не меньше min_room_size
		var room_width = randi_range(min_room_size, min(node.rect.size.x, max_room_size))
		var room_height = randi_range(min_room_size, min(node.rect.size.y, max_room_size))
		
		var x = node.rect.position.x + randi_range(0, node.rect.size.x - room_width)
		var y = node.rect.position.y + randi_range(0, node.rect.size.y - room_height)
		
		node.room_rect = Rect2i(x, y, room_width, room_height)
		
		for cx in range(x, x + room_width):
			for cy in range(y, y + room_height):
				floor_cells.append(Vector2i(cx, cy))

func _create_corridors(node) -> void:
	if node.left and node.right:
		_create_corridors(node.left)
		_create_corridors(node.right)
		
		var left_room = _get_room_center(node.left)
		var right_room = _get_room_center(node.right)
		
		if left_room and right_room:
			_create_hallway(left_room, right_room)

func _get_room_center(node):
	if node.room_rect:
		var center = node.room_rect.get_center()
		return Vector2i(floor(center.x), floor(center.y))
	
	if node.left:
		var left_center = _get_room_center(node.left)
		if left_center:
			return left_center
	if node.right:
		return _get_room_center(node.right)
	
	return null

# Коридоры добавляются в floor_cells (это пол!)
func _create_hallway(from: Vector2i, to: Vector2i) -> void:
	var current = from
	
	while current.x != to.x:
		# Добавляем клетку коридора в пол
		if not floor_cells.has(current):
			floor_cells.append(current)
		current.x += 1 if current.x < to.x else -1
	
	while current.y != to.y:
		if not floor_cells.has(current):
			floor_cells.append(current)
		current.y += 1 if current.y < to.y else -1
	
	# Добавляем конечную точку
	if not floor_cells.has(to):
		floor_cells.append(to)

class _BSPNode:
	var rect: Rect2i
	var left
	var right
	var room_rect: Rect2i
	
	func _init(r: Rect2i):
		rect = r
