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
@export var sword_z_index_left: int = 2
@export var sword_z_index_up: int = -1
@export var sword_z_index_down: int = 2
@export var sword_z_index_default: int = -1

@onready var animation = $AnimatedSprite2D
@onready var sword = $Sword
@onready var sword_sprite = $Sword/AnimatedSprite2D
@onready var health_label = $"../UI/HealthLabel"

var is_attacking: bool = false
var can_attack: bool = true
var attack_cooldown: float = 0.1
var last_direction: String = "down"
var attack_progress: float = 0.0
var attack_start_angle: float = 0.0
var attack_target_angle: float = 0.0
var attack_duration: float = 0.2

# Ноклип
var noclip_active: bool = false
var original_collision_mask: int
var original_collision_layer: int

const SWORD_RADIUS: int = 8
const SWORD_ARC: float = deg_to_rad(85)
const EARLY_OFFSET: float = deg_to_rad(40)

func _ready():
	update_health_display()

func _physics_process(delta):
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	var current_speed = speed
	var is_sprinting = Input.is_action_pressed("sprint")
	if is_sprinting:
		current_speed = sprint_speed
	
	velocity = input_direction * current_speed
	move_and_slide()
	
	if not is_attacking:
		update_animation(input_direction, is_sprinting)
	else:
		update_attack_position(delta)
	
	check_attack_input()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_n"):
		_toggle_noclip()

func _toggle_noclip():
	noclip_active = not noclip_active
	
	if noclip_active:
		original_collision_mask = collision_mask
		original_collision_layer = collision_layer
		collision_mask = 0
		collision_layer = 0
		modulate = Color(1, 1, 1, 0.5)
		print("Ноклип ВКЛЮЧЁН")
	else:
		collision_mask = original_collision_mask
		collision_layer = original_collision_layer
		modulate = Color(1, 1, 1, 1)
		print("Ноклип ВЫКЛЮЧЁН")

func take_damage(amount: int):
	if noclip_active:
		return
	
	current_health -= amount
	print("Игрок получил урон! Осталось здоровья: ", current_health)
	
	update_health_display()
	
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die():
	print("Игрок погиб!")
	
	is_attacking = false
	can_attack = false
	set_physics_process(false)
	
	if sword:
		sword.visible = false
	
	animation.play("die")
	collision_layer = 0
	collision_mask = 0
	
	await animation.animation_finished
	animation.play("dead")
	
	await get_tree().create_timer(3.0).timeout
	
	print("Воскрешение!")
	
	# Проверяем, существует ли дерево и сцена
	if not get_tree():
		print("Ошибка: дерево не найдено")
		return
	
	if get_tree().current_scene == null:
		print("Ошибка: текущая сцена не найдена")
		return
	
	get_tree().reload_current_scene()

func update_health_display():
	if health_label:
		health_label.text = "HP: " + str(current_health) + "/" + str(max_health)

func update_attack_position(delta):
	attack_progress += delta / attack_duration
	
	if attack_progress >= 1.0:
		attack_progress = 1.0
	
	var current_angle = lerp(attack_start_angle, attack_target_angle, attack_progress)
	
	var base_pos = Vector2(
		cos(current_angle) * SWORD_RADIUS,
		sin(current_angle) * SWORD_RADIUS
	)
	
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
	if is_attacking or not can_attack or noclip_active:
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
		
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				last_direction = "right"
				animation.play(anim_prefix + "_right")
			else:
				last_direction = "left"
				animation.play(anim_prefix + "_left")
		else:
			if direction.y > 0:
				last_direction = "down"
				animation.play(anim_prefix + "_down")
			else:
				last_direction = "up"
				animation.play(anim_prefix + "_up")
		
		if not is_attacking:
			update_sword_position(last_direction)
	else:
		animation.play("idle")

func update_sword_position(direction: String):
	if not sword or is_attacking:
		return
	
	sword.z_index = sword_z_index_default
	
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
	if not can_attack or is_attacking or noclip_active:
		return
	
	is_attacking = true
	can_attack = false
	attack_progress = 0.0
	
	if sword and sword.has_method("start_attack"):
		sword.start_attack()
	
	match last_direction:
		"right":
			sword.z_index = sword_z_index_right
		"left":
			sword.z_index = sword_z_index_left
		"up":
			sword.z_index = sword_z_index_up
		"down":
			sword.z_index = sword_z_index_down
	
	match last_direction:
		"right":
			attack_start_angle = SWORD_ARC/2 + EARLY_OFFSET
			attack_target_angle = -SWORD_ARC/2 + EARLY_OFFSET
		"left":
			attack_start_angle = PI + SWORD_ARC/2 - EARLY_OFFSET
			attack_target_angle = PI - SWORD_ARC/2 - EARLY_OFFSET
		"up":
			attack_start_angle = -PI/2 + SWORD_ARC/2 + EARLY_OFFSET
			attack_target_angle = -PI/2 - SWORD_ARC/2 + EARLY_OFFSET
		"down":
			attack_start_angle = PI/2 + SWORD_ARC/2 - EARLY_OFFSET
			attack_target_angle = PI/2 - SWORD_ARC/2 - EARLY_OFFSET
	
	animation.play("attack_" + last_direction)
	
	if sword:
		sword.visible = true
		sword_sprite.play("swing_" + last_direction)
	
	await animation.animation_finished
	finish_attack()

func finish_attack():
	is_attacking = false
	
	if sword and sword.has_method("end_attack"):
		sword.end_attack()
	
	if sword:
		sword.visible = false
		sword_sprite.stop()
		sword.z_index = sword_z_index_default
	
	update_sword_position(last_direction)
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func heal(amount: int):
	if current_health >= max_health:
		return
	
	current_health = min(current_health + amount, max_health)
	update_health_display()
	
	modulate = Color.GREEN
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
