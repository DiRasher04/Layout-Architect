extends CharacterBody2D

# Скорости
@export var speed: float = 250.0
@export var sprint_speed: float = 400.0

@onready var animation = $AnimatedSprite2D

func _physics_process(delta):
	# Получаем вектор движения (-1..1)
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Определяем текущую скорость (обычная или ускорение)
	var current_speed = speed
	var is_sprinting = Input.is_action_pressed("shift")
	if is_sprinting:
		current_speed = sprint_speed
	
	# Применяем скорость
	velocity = input_direction * current_speed
	move_and_slide()
	
	# Обработка анимаций
	update_animation(input_direction, is_sprinting)
	
func update_animation(direction: Vector2, is_sprinting: bool):
	if direction.length() > 0:
		var anim_prefix = "walk"
		if is_sprinting:
			anim_prefix = "run"
		
		# Определяем основное направление (по максимальной оси)
		if abs(direction.x) > abs(direction.y):
			# Горизонталь
			if direction.x > 0:
				animation.play(anim_prefix + "_right")
			else:
				animation.play(anim_prefix + "_left")
		else:
			# Вертикаль
			if direction.y > 0:
				animation.play(anim_prefix + "_down")
			else:
				animation.play(anim_prefix + "_up")
	else:
		animation.play("idle")
