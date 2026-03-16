extends CharacterBody2D

# Скорости
@export var speed: float = 250.0
@export var sprint_speed: float = 400.0

# Здоровье игрока
@export var max_health: int = 5
@export var current_health: int = 5

# Смещения меча для каждой стороны (можно настроить в инспекторе)
@export var sword_offset_right: Vector2 = Vector2(0, -2)
@export var sword_offset_left: Vector2 = Vector2(-1, -4)
@export var sword_offset_up: Vector2 = Vector2(-1, 2)
@export var sword_offset_down: Vector2 = Vector2(0, 0)

# Z-индекс меча для разных направлений
@export var sword_z_index_right: int = -1
@export var sword_z_index_left: int = 2  # выше при атаке влево
@export var sword_z_index_up: int = -1
@export var sword_z_index_down: int = 2  # выше при атаке вниз
@export var sword_z_index_default: int = -1  # обычный Z-индекс

@onready var animation = $AnimatedSprite2D
@onready var sword = $Sword  # узел с мечом (Area2D)
@onready var sword_sprite = $Sword/AnimatedSprite2D  # ссылка на анимацию меча
@onready var health_label = $"../UI/HealthLabel"  # путь к Label с HP (настрой под свою сцену)

var is_attacking: bool = false
var can_attack: bool = true
var attack_cooldown: float = 0.1  # задержка между атаками
var last_direction: String = "down"  # последнее направление движения
var attack_progress: float = 0.0  # прогресс атаки (0..1)
var attack_start_angle: float = 0.0  # начальный угол меча
var attack_target_angle: float = 0.0  # конечный угол меча
var attack_duration: float = 0.2  # длительность атаки в секундах

# Константы для позиционирования меча
const SWORD_RADIUS: int = 8  # радиус вращения меча (расстояние от центра)
const SWORD_ARC: float = deg_to_rad(85)  # 70 градусов в радианах
const EARLY_OFFSET: float = deg_to_rad(40)  # смещение на 15 градусов

func _ready():
	update_health_display()

func _physics_process(delta):
	# ДВИЖЕНИЕ: WASD
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Определяем текущую скорость (обычная или ускорение)
	var current_speed = speed
	var is_sprinting = Input.is_action_pressed("sprint")
	if is_sprinting:
		current_speed = sprint_speed
	
	# Применяем скорость
	velocity = input_direction * current_speed
	move_and_slide()
	
	# Обработка анимаций движения (если не атакуем)
	if not is_attacking:
		update_animation(input_direction, is_sprinting)
	else:
		# Обновляем позицию меча во время атаки
		update_attack_position(delta)
	
	# АТАКА: только по отдельным кнопкам (стрелки)
	check_attack_input()

# Функция получения урона (вызывается врагом)
func take_damage(amount: int):
	current_health -= amount
	print("Игрок получил урон! Осталось здоровья: ", current_health)
	
	# Обновляем UI
	update_health_display()
	
	# Визуальный эффект получения урона
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# Проверка на смерть
	if current_health <= 0:
		die()

func die():
	print("Игрок погиб!")
	
	# Отключаем управление и атаку
	is_attacking = false
	can_attack = false
	set_physics_process(false)  # останавливаем _physics_process
	
	# Прячем меч
	if sword:
		sword.visible = false
	
	# Проигрываем анимацию смерти
	animation.play("die")
	collision_layer = 0
	collision_mask = 0
	
	# Ждём окончания анимации смерти
	await animation.animation_finished
	
	# Переключаемся на статичную анимацию "dead"
	# (игрок лежит мёртвый, но не исчезает)
	animation.play("dead")
	
	# Камера остаётся на месте ещё 3 секунды
	print("Камера смотрит на место смерти...")
	await get_tree().create_timer(3.0).timeout
	
	# Воскрешение — перезапуск сцены
	print("Воскрешение!")
	get_tree().reload_current_scene()

func update_health_display():
	if health_label:
		health_label.text = "HP: " + str(current_health) + "/" + str(max_health)

# ... остальные функции (update_attack_position, check_attack_input, update_animation и т.д.) остаются без изменений ...

func update_attack_position(delta):
	attack_progress += delta / attack_duration
	
	if attack_progress >= 1.0:
		attack_progress = 1.0
	
	# Интерполируем угол от начального до конечного
	var current_angle = lerp(attack_start_angle, attack_target_angle, attack_progress)
	
	# Базовая позиция по окружности
	var base_pos = Vector2(
		cos(current_angle) * SWORD_RADIUS,
		sin(current_angle) * SWORD_RADIUS
	)
	
	# Добавляем смещение в зависимости от направления
	match last_direction:
		"right":
			sword.position = base_pos + sword_offset_right
		"left":
			sword.position = base_pos + sword_offset_left
		"up":
			sword.position = base_pos + sword_offset_up
		"down":
			sword.position = base_pos + sword_offset_down

func check_attack_input():
	if is_attacking or not can_attack:
		return
	
	var attack_pressed = false
	var attack_dir = ""
	
	if Input.is_action_just_pressed("attack_up"):
		attack_dir = "up"
		attack_pressed = true
	elif Input.is_action_just_pressed("attack_down"):
		attack_dir = "down"
		attack_pressed = true
	elif Input.is_action_just_pressed("attack_left"):
		attack_dir = "left"
		attack_pressed = true
	elif Input.is_action_just_pressed("attack_right"):
		attack_dir = "right"
		attack_pressed = true
	
	if attack_pressed:
		last_direction = attack_dir
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
		
		# Обновляем позицию меча в зависимости от направления (только когда не атакуем)
		if not is_attacking:
			update_sword_position(last_direction)
	else:
		animation.play("idle")

func update_sword_position(direction: String):
	if not sword or is_attacking:
		return
	
	# В обычном состоянии меч имеет обычный Z-индекс
	sword.z_index = sword_z_index_default
	
	# В обычном состоянии меч просто висит сбоку
	var base_angle = 0.0
	match direction:
		"right":
			base_angle = 0.0
			sword.position = Vector2(cos(base_angle) * SWORD_RADIUS, sin(base_angle) * SWORD_RADIUS) + sword_offset_right
		"left":
			base_angle = PI
			sword.position = Vector2(cos(base_angle) * SWORD_RADIUS, sin(base_angle) * SWORD_RADIUS) + sword_offset_left
		"up":
			base_angle = -PI/2
			sword.position = Vector2(cos(base_angle) * SWORD_RADIUS, sin(base_angle) * SWORD_RADIUS) + sword_offset_up
		"down":
			base_angle = PI/2
			sword.position = Vector2(cos(base_angle) * SWORD_RADIUS, sin(base_angle) * SWORD_RADIUS) + sword_offset_down

func attack():
	if not can_attack or is_attacking:
		return
	
	is_attacking = true
	can_attack = false
	attack_progress = 0.0
	
	# Сообщаем мечу о начале атаки
	if sword and sword.has_method("start_attack"):
		sword.start_attack()
	
	# Устанавливаем Z-индекс в зависимости от направления атаки
	match last_direction:
		"right":
			sword.z_index = sword_z_index_right
		"left":
			sword.z_index = sword_z_index_left
		"up":
			sword.z_index = sword_z_index_up
		"down":
			sword.z_index = sword_z_index_down
	
	# Определяем начальный и конечный угол с ранним началом/окончанием
	match last_direction:
		"right":
			# По часовой стрелке: от +50° до -20° (вместо +35° до -35°)
			attack_start_angle = SWORD_ARC/2 + EARLY_OFFSET
			attack_target_angle = -SWORD_ARC/2 + EARLY_OFFSET
		"left":
			# По часовой стрелке: от 180+50° до 180-20°
			attack_start_angle = PI + SWORD_ARC/2 - EARLY_OFFSET
			attack_target_angle = PI - SWORD_ARC/2 - EARLY_OFFSET
		"up":
			# По часовой стрелке: от -90+50° до -90-20°
			attack_start_angle = -PI/2 + SWORD_ARC/2 + EARLY_OFFSET
			attack_target_angle = -PI/2 - SWORD_ARC/2 + EARLY_OFFSET
		"down":
			# По часовой стрелке: от 90+50° до 90-20°
			attack_start_angle = PI/2 + SWORD_ARC/2 - EARLY_OFFSET
			attack_target_angle = PI/2 - SWORD_ARC/2 - EARLY_OFFSET
	
	# Проигрываем анимацию атаки персонажа
	animation.play("attack_" + last_direction)
	
	# Меч становится видимым и проигрывает анимацию взмаха
	if sword:
		sword.visible = true
		sword_sprite.play("swing_" + last_direction)
	
	await animation.animation_finished
	finish_attack()

func finish_attack():
	is_attacking = false
	
	# Сообщаем мечу о завершении атаки
	if sword and sword.has_method("end_attack"):
		sword.end_attack()
	
	# Прячем меч и возвращаем обычный Z-индекс
	if sword:
		sword.visible = false
		sword_sprite.stop()  # останавливаем анимацию
		sword.z_index = sword_z_index_default  # возвращаем обычный Z-индекс
	
	# Возвращаем меч в обычное положение
	update_sword_position(last_direction)
	
	# Ждём перезарядку
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func heal(amount: int):
	if current_health >= max_health:
		return  # Уже полное здоровье
	
	current_health = min(current_health + amount, max_health)
	update_health_display()
	
	# Визуальный эффект (зеленый вместо красного)
	modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
