extends CharacterBody2D

# Как быстро персонаж бегает
@export var speed: float = 300.0
@export var sprint_speed: float = 500.0  # скорость при ускорении
@onready var animation = $AnimatedSprite2D

func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Проверяем, зажат ли Shift
	var current_speed = speed
	if Input.is_action_pressed("shift"):  # если Shift зажат
		current_speed = sprint_speed
		# Можно добавить анимацию спринта, если есть
		# animation.play("sprint")
	
	# Применяем скорость
	velocity = input_direction * current_speed
	
	# Двигаем персонажа
	move_and_slide()
	
	# Анимации
	if input_direction.length() > 0:  # Если персонаж двигается
		animation.play("walk")
	else:  # Если стоит
		animation.play("idle")
