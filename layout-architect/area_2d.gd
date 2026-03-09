extends Area2D

@export var damage: int = 1  # урон
@export var lifetime: float = 0.3  # сколько живет меч

@onready var sprite = $Sprite2D
@onready var timer = $Timer

func _ready():
	# Настраиваем таймер
	timer.wait_time = lifetime
	timer.start()
	
	# Подключаем сигналы
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_timer_timeout)
	
	# Можно проиграть анимацию
	if sprite is AnimatedSprite2D:
		sprite.play("attack")

func _on_body_entered(body: Node2D):
	# Проверяем, враг ли это
	if body.has_method("take_damage"):  # если у врага есть метод take_damage
		body.take_damage(damage)
	# Или через группы
	elif body.is_in_group("enemies"):
		# Здесь наносим урон
		body.health -= damage
		print("Попадание! У врага осталось: ", body.health)

func _on_timer_timeout():
	queue_free()  # меч исчезает
