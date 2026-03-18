extends Area2D

class_name HealthPack

@export var heal_amount: int = 1
@export var pickup_delay: float = 0.5

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var can_pickup: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	
	animation.play("default")
	
	await get_tree().create_timer(pickup_delay).timeout
	can_pickup = true

func _on_body_entered(body):
	# Добавь в _on_body_entered после проверки на полное здоровье:

	if not can_pickup:
		return
	
	# Проверяем, что это игрок
	if body.has_method("heal") and body.has_method("take_damage"):
		# ПРОВЕРЯЕМ: нужно ли вообще лечение?
		if body.current_health >= body.max_health:
			# У игрока полное здоровье - ничего не делаем
			return
			
		# Лечим игрока
		body.heal(heal_amount)
		pickup()

func pickup():
	collision.set_deferred("disabled", true)
	can_pickup = false
	
	animation.play("pickup")
	await animation.animation_finished
	
	queue_free()
