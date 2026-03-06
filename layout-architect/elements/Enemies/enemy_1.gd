extends CharacterBody2D

@onready var animation = $AnimatedSprite2D
var speed = 200
var player = null

func _physics_process(delta: float) -> void:
	if player:
		var dir = (player.position - position).normalized()
		velocity = speed * dir
		move_and_slide()
	else:
		velocity = Vector2(0,0)


func _on_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body


func _on_detector_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player = null


func _ready() -> void:
	animation.play("default")
