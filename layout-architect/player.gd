extends CharacterBody2D

# Как быстро персонаж бегает
@export var speed: float = 350.0
@onready var animation = $AnimatedSprite2D

func _physics_process(delta):
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# Применяем скорость
	velocity = input_direction * speed
	# Двигаем персонажа
	move_and_slide()
	if input_direction.length() > 0:  # Если персонаж двигается
		animation.play("walk")  # Замени "walk" на имя твоей анимации
	else:  # Если стоит
		animation.play("idle")  # Замени "idle" на имя твоей анимации покоя
