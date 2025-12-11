extends CharacterBody2D
class_name Boat

@onready var visual: Node2D = $Visual
@onready var anim: AnimatedSprite2D = $Visual/AnimatedSprite2D

@export var acceleration: float = 100.0
@export var max_speed: float = 80.0
@export var friction: float = 250.0
@export var turn_speed: float = 3.0
@export var knockback_duration: float = 0.25
@export var collision_pushback: float = 7.5
@export var collision_nudge: float = 2.0  

@export var drunk_turn_wobble_deg: float = 8.0
@export var drunk_lateral_strength: float = 100.0
@export var drunk_friction_factor: float = 0.6

var fishing := false
var showing_ui := false
var knockback_time := 0.0
var drunk_amount: float = 0

var movingBoatSoundEvent: FmodEvent = null
var isPlayingSound := false

var _last_dir := 0

func _ready() -> void:
	GameManager.boat = self
	_init_sounds()

func _physics_process(delta: float) -> void:
	if fishing or showing_ui: return
	
	if knockback_time <= 0.0:
		knockback_time = 0.0
		var turn_input := Input.get_axis("ui_left", "ui_right")
		var thrust_input := Input.get_axis("ui_down", "ui_up")  
		
		rotation -= -turn_input * turn_speed * delta
		if drunk_amount > 0.0 and thrust_input != 0.0:
			var max_wobble_rad := deg_to_rad(drunk_turn_wobble_deg) * drunk_amount
			var wobble := randf_range(-max_wobble_rad, max_wobble_rad)
			rotation += wobble
			
		visual.rotation = -rotation
		
		var forward := Vector2.UP.rotated(rotation)
		
		if thrust_input != 0.0:
			velocity += forward * thrust_input * acceleration * delta
			if drunk_amount > 0.0:
				var right := forward.orthogonal()
				var lateral_jitter := randf_range(-1.0, 1.0)
				velocity += right * lateral_jitter * drunk_lateral_strength * drunk_amount * delta
		else:
			if velocity.length() > 0.0:
				var v_dir := velocity.normalized()
				var v_mag := velocity.length()
				var current_friction: float = lerp(friction, friction * drunk_friction_factor, drunk_amount)
				v_mag = max(v_mag - current_friction * delta, 0.0)
				velocity = v_dir * v_mag
		
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
		
		_update_sprite_direction()
		_update_boat_movement_sound(velocity)
	
	else: knockback_time -= delta

	move_and_slide()
	_check_collisions()	
	
func _update_sprite_direction() -> void:
	
	var facing := Vector2.UP.rotated(rotation)
	var angle := facing.angle()          # 0 = derecha, PI/2 = abajo, -PI/2 = arriba, PI = izquierda

	var step := PI / 4.0                 # 45º por sector
	var dir := int(round(angle / step)) % 8
	if dir < 0:
		dir += 8
	_last_dir = dir
	
	match dir:
		0: # derecha
			anim.flip_h = false
			anim.play("right")
	
		1: # abajo-derecha
			anim.flip_h = false
			anim.play("down_right")
	
		2: # abajo
			anim.flip_h = false
			anim.play("down")
	
		3: # abajo-izquierda (espejo de abajo-dcha)
			anim.flip_h = true
			anim.play("down_right")
	
		4: # izquierda (espejo de derecha)
			anim.flip_h = true
			anim.play("right")
	
		5: # arriba-izquierda (espejo de arriba-dcha)
			anim.flip_h = true
			anim.play("up_right")
	
		6: # arriba
			anim.flip_h = false
			anim.play("up")
	
		7: # arriba-derecha
			anim.flip_h = false
			anim.play("up_right")
	
	
func _check_collisions() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		
		if knockback_time == 0.0 and collider is Node and (collider as Node).is_in_group("damage_zone"):
			var normal: Vector2 = collision.get_normal()
			knockback_time = knockback_duration
			global_position += normal * collision_nudge
			var vel_into_wall := velocity.dot(normal)
			if vel_into_wall < 0.0:
				velocity -= normal * vel_into_wall
			velocity += normal * collision_pushback
			
			GameManager.update_life()
			
# SOUND

func _init_sounds() -> void:
	movingBoatSoundEvent = FmodServer.create_event_instance("event:/BoatMovement")
	movingBoatSoundEvent.paused = true
	movingBoatSoundEvent.start()
	
func _update_boat_movement_sound(velocity: Vector2) -> void:
	if velocity.length() > 0.0 && !isPlayingSound:
		isPlayingSound = true
		movingBoatSoundEvent.set_parameter_by_name('BoatMovement', 0)
		movingBoatSoundEvent.start()
		movingBoatSoundEvent.paused = false
		
	if velocity.length() == 0.0 && isPlayingSound:
		movingBoatSoundEvent.set_parameter_by_name('BoatMovement', 1)
		isPlayingSound = false
