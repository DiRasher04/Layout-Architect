extends Area2D

@export var damage: int = 9
@export var attack_duration: float = 0.4  # время анимации атаки
@export var swing_angle: float = 150.0  # угол поворота в градусах

var target_angle: float = 0.0
var start_angle: float = 0.0
var time_passed: float = 0.0
var is_attacking: bool = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	# Подключаем сигнал попадания
	body_entered.connect(_on_body_entered)
	# Изначально меч не активен
	set_attack_active(false)

func set_attack_active(active: bool):
	is_attacking = active
	collision.disabled = not active  # включаем/выключаем коллизию
	visible = active  # показываем/прячем меч
	if active:
		time_passed = 0.0
		# Меч появляется справа от игрока
		start_angle = 0.0
		target_angle = deg_to_rad(swing_angle)  # переводим в радианы
		rotation = start_angle
	else:
		rotation = 0.0  # сбрасываем поворот

func _process(delta):
	if is_attacking:
		time_passed += delta
		var progress = time_passed / attack_duration  # от 0 до 1
		
		# Интерполяция угла (линейная)
		var current_angle = lerp(start_angle, target_angle, progress)
		rotation = current_angle
		
		# Если атака закончилась
		if progress >= 1.0:
			set_attack_active(false)

func _on_body_entered(body):
	if is_attacking and body.has_method("take_damage"):
		body.take_damage(damage)
		# Чтобы не наносить урон несколько раз за одну атаку
		set_attack_active(false)
