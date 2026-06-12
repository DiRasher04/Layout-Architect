extends Node

# Выбранный алгоритм (0=BSP, 1=Cellular, 2=Hybrid)
var selected_algorithm: int = 0

# BSP параметры (значения по умолчанию)
var bsp_min_room_size: int = 10
var bsp_max_room_size: int = 20
var bsp_max_split_iterations: int = 10
var bsp_corridor_thickness: int = 3
var bsp_corridor_variation: int = 8
var bsp_corridor_jitter: float = 0.7
var bsp_add_mid_points: bool = true
