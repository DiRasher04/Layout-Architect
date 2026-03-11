extends CharacterBody2D

@export var health: int = 3
@export var speed: int = 200
@export var attack_speed: int = 400  # скорость рывка при атаке
@export var attack_range: float = 150.0  # дистанция, с которой начинает атаку
@export var attack_cooldown: float = 0.5  # задержка ПОСЛЕ атаки (секунд)
@export var attack_windup: float = 0.5  # задержка ПЕРЕД атакой (секунд)
@export var damage: int = 1  # урон игроку

@onready var animation = $AnimatedSprite2D

var player = null
var is_alive: bool = true
var is_attacking: bool = false
var can_attack: bool = true
var attack_target_position: Vector2 = Vector2.ZERO  # позиция, куда лететь в рывке
var attack_direction: String = "right"  # направление атаки для анимации
var is_on_pause: bool = false  # флаг паузы (стояние на месте)

func _ready():
	animation.play("idle")

func _physics_process(delta):
	if not is_alive or is_on_pause:
		# Если на паузе — стоим на месте
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if is_attacking:
		# Рывок к цели
		var dir = (attack_target_position - position).normalized()
		velocity = attack_speed * dir
		move_and_slide()
		
		# Проверяем, долетели ли
		if position.distance_to(attack_target_position) < 10:
			finish_attack()
		return
	
	if player:
		var dist = position.distance_to(player.position)
		var dir = (player.position - position).normalized()
		
		if dist <= attack_range and can_attack:
			# Начинаем атаку
			start_attack()
		else:
			# Идём к игроку
			velocity = speed * dir
			update_movement_animation(dir)
			move_and_slide()
	else:
		velocity = Vector2.ZERO
		animation.play("idle")

func update_movement_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			animation.play("walk_right")
			attack_direction = "right"
		else:
			animation.play("walk_left")
			attack_direction = "left"
	else:
		animation.play("walk_right" if dir.x > 0 else "walk_left")

func start_attack():
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO
	
	# Запоминаем позицию игрока для рывка
	attack_target_position = player.position
	
	# Проигрываем анимацию атаки
	animation.play("attack_" + attack_direction)
	
	# ПАУЗА ПЕРЕД АТАКОЙ (стоим на месте)
	is_on_pause = true
	await get_tree().create_timer(attack_windup).timeout
	is_on_pause = false
	
	# Если враг ещё жив и игрок рядом, начинаем рывок
	if is_attacking and is_alive and player:
		# Рывок продолжится в _physics_process
		pass
	else:
		# Если что-то пошло не так, отменяем атаку
		is_attacking = false
		can_attack = true

func finish_attack():
	is_attacking = false
	
	# Наносим урон игроку, если он рядом
	if player and position.distance_to(player.position) < 40:
		if player.has_method("take_damage"):
			player.take_damage(damage)
			print("Враг нанёс урон игроку!")
	
	# Возвращаемся в idle
	animation.play("idle")
	
	# ПАУЗА ПОСЛЕ АТАКИ (стоим на месте)
	is_on_pause = true
	await get_tree().create_timer(attack_cooldown).timeout
	is_on_pause = false
	
	can_attack = true

# Функция, которую вызывает меч игрока
func take_damage(amount: int):
	health -= amount
	print("Враг получил урон! Осталось здоровья: ", health)
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	is_alive = false
	velocity = Vector2.ZERO
	animation.play("die")
	await animation.animation_finished
	queue_free()

func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body

func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
		# Если враг атаковал, а игрок вышел из зоны
		is_attacking = false
		can_attack = true
		is_on_pause = false
