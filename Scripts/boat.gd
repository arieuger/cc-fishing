extends CharacterBody2D

@export var acceleration: float = 100.0
@export var max_speed: float = 80.0
@export var friction: float = 250.0
@export var turn_speed: float = 3.0


func _physics_process(delta: float) -> void:
	var turn_input := Input.get_axis("ui_left", "ui_right")
	var thrust_input := Input.get_axis("ui_down", "ui_up")  

	rotation -= -turn_input * turn_speed * delta

	var forward := Vector2.UP.rotated(rotation)

	if thrust_input != 0.0:
		velocity += forward * thrust_input * acceleration * delta
	else:
		if velocity.length() > 0.0:
			var v_dir := velocity.normalized()
			var v_mag := velocity.length()
			v_mag = max(v_mag - friction * delta, 0.0)
			velocity = v_dir * v_mag

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	move_and_slide()

	
