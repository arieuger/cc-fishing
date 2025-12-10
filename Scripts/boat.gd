extends CharacterBody2D
class_name Boat

@export var acceleration: float = 100.0
@export var max_speed: float = 80.0
@export var friction: float = 250.0
@export var turn_speed: float = 3.0
@export var knockback_duration: float = 0.25
@export var collision_pushback: float = 7.5
@export var collision_nudge: float = 2.0  

var fishing := false
var showing_ui := false
var knockback_time := 0.0

var movingBoatSoundEvent: FmodEvent = null
var isPlayingSound := false

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
		
		_update_boat_movement_sound(velocity)
	
	else: knockback_time -= delta

	move_and_slide()
	_check_collisions()	
	
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
