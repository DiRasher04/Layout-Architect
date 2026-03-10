extends CharacterBody2D

# Скорости
@export var speed: float = 250.0
@export var sprint_speed: float = 400.0

@onready var animation = $AnimatedSprite2D
@onready var sword = $Sword  # узел с мечом (Area2D)
@onready var sword_sprite = $Sword/AnimatedSprite2D  # ссылка на анимацию меча

var is_attacking: bool = false
var can_attack: bool = true
var attack_cooldown: float = 0.2  # задержка между атаками
var last_direction: String = "down"  # последнее направление движения

# Константы для позиционирования меча
const SWORD_OFFSET: int = -2  # на сколько пикселей меч отодвинут от центра

func _physics_process(delta):
	if is_attacking:
		# Во время атаки не двигаемся
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
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
	
	# Атака по пробелу
	if Input.is_action_just_pressed("ui_accept") and can_attack:
		attack()

func update_animation(direction: Vector2, is_sprinting: bool):
	if direction.length() > 0:
		var anim_prefix = "walk"
		if is_sprinting:
			anim_prefix = "run"
		
		# Определяем основное направление (по максимальной оси)
		if abs(direction.x) > abs(direction.y):
			# Горизонталь
			if direction.x > 0:
				last_direction = "right"
				animation.play(anim_prefix + "_right")
			else:
				last_direction = "left"
				animation.play(anim_prefix + "_left")
		else:
			# Вертикаль
			if direction.y > 0:
				last_direction = "down"
				animation.play(anim_prefix + "_down")
			else:
				last_direction = "up"
				animation.play(anim_prefix + "_up")
		
		# Обновляем позицию меча в зависимости от направления
		update_sword_position(last_direction)
	else:
		animation.play("idle")

func update_sword_position(direction: String):
	if not sword:
		return
	
	match direction:
		"right":
			sword.position = Vector2(SWORD_OFFSET, 0)
			sword.scale.x = abs(sword.scale.x)
		"left":
			sword.position = Vector2(-SWORD_OFFSET, 0)
			sword.scale.x = abs(sword.scale.x)
		"up":
			sword.position = Vector2(0, -SWORD_OFFSET)
			sword.scale.x = abs(sword.scale.x)
		"down":
			sword.position = Vector2(0, SWORD_OFFSET)
			sword.scale.x = abs(sword.scale.x)

func attack():
	if not can_attack or is_attacking:
		return
	
	
	is_attacking = true
	can_attack = false
	
	animation.stop()
	animation.play("attack_" + last_direction)
	
	if sword:
		sword.visible = true
		sword_sprite.play("swing_" + last_direction)
		
		match last_direction:
			"right":
				sword.position = Vector2(SWORD_OFFSET + 10, 0)
			"left":
				sword.position = Vector2(-SWORD_OFFSET - 10, 0)
			"up":
				sword.position = Vector2(0, -SWORD_OFFSET - 10)
			"down":
				sword.position = Vector2(0, SWORD_OFFSET + 10)
	
	await animation.animation_finished
	finish_attack()

func finish_attack():
	is_attacking = false
	
	# Прячем меч
	if sword:
		sword.visible = false
		sword_sprite.stop()
		# Возвращаем меч на обычную позицию (обновится при следующем движении)
	
	# Возвращаемся в покой
	animation.play("idle")
	
	# Ждём перезарядку
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
