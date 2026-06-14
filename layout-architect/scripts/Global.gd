extends Node

# Выбранный алгоритм (0=BSP, 1=Cellular, 2=Hybrid)
var selected_algorithm: int = 0

# Общие параметры карты
var map_width: int = 60
var map_height: int = 60
var wall_thickness: int = 4

# BSP параметры
var bsp_min_room_size: int = 10
var bsp_max_room_size: int = 20
var bsp_max_split_iterations: int = 10
var bsp_corridor_thickness: int = 3
var bsp_corridor_variation: int = 8
var bsp_corridor_jitter: float = 0.7
var bsp_add_mid_points: bool = true

# Cellular Automata параметры
var cellular_fill_probability: float = 0.45
var cellular_iterations: int = 4
var cellular_birth_limit: int = 4
var cellular_death_limit: int = 4

# Hybrid параметры
var hybrid_min_room_size: int = 10
var hybrid_max_room_size: int = 15
var hybrid_cellular_noise: float = 0.5
