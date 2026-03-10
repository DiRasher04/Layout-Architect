extends Area2D

@export var damage: int = 1

func _ready():
	# Подключаем сигнал попадания
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Если меч видим (идёт атака) и у объекта есть метод take_damage
	if visible and body.has_method("take_damage"):
		body.take_damage(damage)
		
		# Опционально: отключаем коллизию после первого попадания
		# чтобы меч не бил несколько раз за одну атаку
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(0.1).timeout
		$CollisionShape2D.disabled = false
