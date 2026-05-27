extends Sprite2D

var original_y: float
var tween: Tween

func _ready():
	original_y = position.y
	_start_floating()

func _start_floating():
	if tween and tween.is_valid():
		tween.kill()
	
	tween = create_tween().set_loops()  # Бесконечный цикл
	tween.tween_property(self, "position:y", original_y - 5, 1.5)  # Вверх
	tween.tween_property(self, "position:y", original_y + 5, 1.5)  # Вниз
