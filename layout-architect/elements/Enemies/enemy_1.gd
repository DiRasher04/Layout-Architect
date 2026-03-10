extends CharacterBody2D

@export var health: int = 3
@export var speed: int = 200
@export var damage_from_player: int = 1  # сколько урона получает от игрока (запас)

@onready var animation = $AnimatedSprite2D

var player = null
var is_alive: bool = true

func _ready():
	animation.play("default")

func _physics_process(delta):
	if not is_alive:
		return
	
	if player:
		var dir = (player.position - position).normalized()
		velocity = speed * dir
		
		# Опционально: поворот анимации в сторону движения
		if abs(dir.x) > abs(dir.y):
			if dir.x > 0:
				animation.play("walk_right")
			else:
				animation.play("walk_left")
		else:
			if dir.y > 0:
				animation.play("walk_down")
			else:
				animation.play("walk_up")
		
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		animation.play("idle")

# Функция, которую вызывает меч
func take_damage(amount: int):
	
	
	health -= amount


	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout

	modulate = Color.WHITE
	
	if health <= 0:
		die()		

func die():
	is_alive = false
	velocity = Vector2.ZERO
	animation.play("death")  # если есть анимация смерти
	await animation.animation_finished  # ждём окончания анимации
	queue_free()  # удаляем врага

func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body

func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null
