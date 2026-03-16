extends Area2D

@export var damage: int = 1

var hit_targets: Array = []  # Кого уже ударили в этой атаке
var can_hit: bool = false  # Разрешено ли наносить удары

func _ready():
	# Подключаем сигнал попадания
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Если не в режиме атаки - выходим
	if not can_hit:
		return
	
	# Проверяем, не били ли мы уже это тело
	if body in hit_targets:
		return
		
	# Если у объекта есть метод take_damage - наносим урон
	if body.has_method("take_damage"):
		body.take_damage(damage)
		hit_targets.append(body)  # Запоминаем, кого ударили

func start_attack():
	# Готовимся к атаке
	can_hit = true
	hit_targets.clear()  # Очищаем список для новой атаки
	# Не отключаем коллизию - она работает, но мы фильтруем через can_hit и hit_targets

func end_attack():
	# Завершаем атаку
	can_hit = false
	# hit_targets можно не чистить, они всё равно не используются пока can_hit = false
