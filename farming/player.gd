extends CharacterBody2D

var speed: int = 200
var move_direction: Vector2 = Vector2(0, 0)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	movement_loop()
	update_animation()

func movement_loop() -> void:
	move_direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	move_direction.y = (int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))) / float(2)
	var motion: Vector2 = move_direction.normalized() * speed
	set_velocity(motion)
	move_and_slide()

func update_animation() -> void:
	var is_moving := velocity.length_squared() > 1.0

	if is_moving:
		var target_anim := "run_horizontal"
		if move_direction.y < 0:
			target_anim = "run_up"
		if sprite.animation != target_anim:
			sprite.play(target_anim)
	else:
		if sprite.animation != "idle":
			sprite.play("idle")

	# Face sprite in movement direction (only when moving horizontally)
	if move_direction.x != 0:
		sprite.flip_h = move_direction.x > 0
