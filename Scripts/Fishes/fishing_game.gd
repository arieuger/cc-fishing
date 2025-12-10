extends Control
class_name FishingGame

@onready var bar: ColorRect = $Bar
@onready var cursor: ColorRect = $Bar/Cursor
@onready var fish: ColorRect = $Bar/Fish
@onready var catch_bar: ProgressBar = $Bar/CatchBar
@onready var fish_ui_panel: Panel = $/root/MainScene/UILayer/FishPanel

@export_range(0.5, 3.0, 0.1)
var difficulty: float = 1.0

var fishing_zone: FishingZone
var fish_data: FishData

var _cursor_norm: float = 0.5 
var _cursor_vel: float = 0.0 
var _fish_norm: float = 0.5
var _fish_vel: float = 1.0
var _catch_progress: float
var _catch_start_delay := 0.5

const CURSOR_ACCEL_RIGHT: float = 9.0
const CURSOR_ACCEL_LEFT: float = 8.0
const CURSOR_MAX_SPEED: float = 2

const FISH_ACCEL: float = 7.0
const FISH_FRICTION: float = 4.0
const FISH_JUMP_CHANCE: float = 0.6
const FISH_JUMP_STRENGTH: float = 1.5
const FISH_MAX_SPEED: float = 1.5

var fishingSoundEvent: FmodEvent = null

func _ready() -> void:
	_catch_progress = catch_bar.value / 100
	difficulty = randf_range(fish_data.min_difficulty, fish_data.max_difficulty)
	_init_sound()
	
func _process(delta: float) -> void:
	_update_cursor(delta, difficulty)
	_update_fish(delta, difficulty)
	_update_visuals()
	_update_sound(true)
	
	if _catch_start_delay > 0.0:
		_catch_start_delay -= delta
		return
		
	_detect_overlapping(delta)
	

func _update_cursor(delta: float, d: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		_cursor_vel += CURSOR_ACCEL_RIGHT * delta * d
	else:
		_cursor_vel -= CURSOR_ACCEL_LEFT * delta * d
		
	_cursor_vel = clamp(_cursor_vel, -CURSOR_MAX_SPEED, CURSOR_MAX_SPEED * d)
	_cursor_norm += _cursor_vel * delta
	_cursor_norm = clamp(_cursor_norm, 0.0, 1.0)
	
	if _cursor_norm == 0.0 and _cursor_vel < 0.0:
		_cursor_vel = 0.0
	elif _cursor_norm == 1.0 and _cursor_vel > 0.0:
		_cursor_vel = 0.0
		
func _update_fish(delta: float, d: float) -> void:
	var random_dir := (randf() * 2.0 - 1.0)
	_fish_vel += random_dir * FISH_ACCEL * delta * d
	_fish_vel -= _fish_vel * FISH_FRICTION * delta * d
	
	if randf() < FISH_JUMP_CHANCE * delta * d:
		_fish_vel += FISH_JUMP_STRENGTH * (randf() * 2.0 - 1.0) * d
		
	_fish_vel = clamp(_fish_vel, -FISH_MAX_SPEED, FISH_MAX_SPEED * d)
	
	_fish_norm += _fish_vel * delta
	_fish_norm = clamp(_fish_norm, 0.0, 1.0)
	
	if _fish_norm == 0.0 and _fish_vel < 0.0:
		_fish_vel *= -0.5
	elif _fish_norm == 1.0 and _fish_vel > 0.0:
		_fish_vel *= -0.5
		
func _update_visuals() -> void:
	var bar_width: float = bar.size.x
	var cursor_w: float = cursor.size.x
	var fish_h: float = fish.size.x
	
	cursor.position.x = (bar_width - cursor_w) * _cursor_norm
	fish.position.x   = (bar_width - fish_h) * _fish_norm
	
func _detect_overlapping(delta: float):
	var cursor_rect: Rect2 = Rect2(cursor.position, cursor.size)
	var fish_rect: Rect2 = Rect2(fish.position, fish.size)
	
	if cursor_rect.intersects(fish_rect, true):
		_catch_progress += 0.3 * delta
	else:
		_catch_progress -= 0.15 * delta
	
	_catch_progress = clamp(_catch_progress, 0.0, 1.0)
	catch_bar.value = _catch_progress * 100.0
	
	if fishing_zone != null and (_catch_progress == 1.0 or _catch_progress == 0.0):
		if _catch_progress == 1.0:
			GameManager.boat.showing_ui = true
			GameManager.fishes_catched_by_level += 1
			fish_ui_panel.visible = true
			(fish_ui_panel.find_child("FishTitle") as RichTextLabel).text = fish_data.display_name
			(fish_ui_panel.find_child("FishDescription") as RichTextLabel).text = fish_data.description
			fish_data.used = true
			if GameManager.can_receive_bottle() and randf() < 0.7:
				GameManager.receive_bottle()
			
		_update_sound(false)
		GameManager.boat.fishing = false
		fishing_zone.queue_free()
		queue_free()

# SOUND
	
func _init_sound() -> void:
	fishingSoundEvent = FmodServer.create_event_instance("event:/Fishing")
	fishingSoundEvent.paused = true
	fishingSoundEvent.start()
	
func _update_sound(start: bool) -> void:
	fishingSoundEvent.paused = !start
