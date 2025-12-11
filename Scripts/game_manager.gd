extends Node

@onready var hearts_panel: BoxContainer = $/root/MainScene/UILayer/FullHearts
@onready var bottle_ui: TextureRect = $/root/MainScene/UILayer/FullBottle
@onready var fish_ui_panel: Panel = $/root/MainScene/UILayer/FishPanel
@export var fish_database: FishDatabase
@export var minimum_fishes_to_bottle: Dictionary[int, int]
@export var drunk_amount_by_level: Dictionary[int, float] = {}

var zone_level := 0
var player_life := 4
var spawn_zones: Dictionary[int, FishSpawner] = {}
var buoys: Dictionary[int, Node2D] = {}
var boat: Boat
var has_bottle := false
var received_bottle_in_level := false
var fishes_catched_by_level := 0
var trails: Array[SeaTrailFollow] = []
var trail_particles: SeaTrailParticles

var musicEvent: FmodEvent = null
var newBottleSoundEvent: FmodEvent = null
var emptyBottleSoundEvent: FmodEvent = null
var boatCrashSoundEvent: FmodEvent = null
var boatRepairedSoundEvent: FmodEvent = null

func _ready() -> void:
	_init_sounds()

func _process(delta: float) -> void:
	if has_bottle and Input.is_action_just_pressed("drink"):
		bottle_ui.visible = false
		_update_bottle_sound(false)
		buoys[zone_level].queue_free()
		zone_level += 1
		received_bottle_in_level = false
		fishes_catched_by_level = 0
		boat.drunk_amount = drunk_amount_by_level[zone_level]
		# if not spawn_zones[zone_level - 1].destroy_fishes():
		# 	spawn_zones[zone_level].spawn_fish()
		_update_music(zone_level)
		
func catch_fish(fish_data: FishData):
	boat.showing_ui = true
	fishes_catched_by_level += 1
	fish_ui_panel.visible = true
	(fish_ui_panel.find_child("FishTitle") as RichTextLabel).text = fish_data.display_name
	(fish_ui_panel.find_child("FishDescription") as RichTextLabel).text = fish_data.description
	fish_data.used = true
	if can_receive_bottle() and (randf() < 0.7 or fishes_catched_by_level == 10):
		receive_bottle()
	if player_life < 4 and randf() <= 0.5:
		player_life += 1
		var heart := _find_first_visible_heart(false)
		if heart != null: heart.visible = true
		(fish_ui_panel.find_child("HeartFound")).visible = true
		_update_boat_health_sound(true)
			
func can_receive_bottle() -> bool:
	return not received_bottle_in_level and fishes_catched_by_level >= minimum_fishes_to_bottle[zone_level]
	
func receive_bottle() -> void:
	has_bottle = true
	received_bottle_in_level = true
	bottle_ui.visible = true
	(fish_ui_panel.find_child("BottleFound")).visible = true
	_update_bottle_sound(true)

func get_random_for_level() -> FishData:
	var candidates: Array[FishData] = []
	for f in fish_database.fishes:
		if zone_level == f.level and not f.used: candidates.append(f)
	
	if candidates.is_empty():
		# volvemos a empezar
		for f in fish_database.fishes: 
			if zone_level == f.level: f.used = false
		return get_random_for_level() 
	
	else: return candidates[randi() % candidates.size()]
	
func update_life(damage := true) -> void:
	if player_life > 0:
		player_life -= 1
		var heart := _find_first_visible_heart()
		if heart != null: heart.visible = false 
		_update_boat_health_sound(false)
	
func _find_first_visible_heart(visible := true) -> Node:
	for h in hearts_panel.get_children():
		if h.visible == visible: return h
	return null

func _on_trail_timer_timeout() -> void:
	var path := trails[randi() % trails.size()]
	trail_particles.attach_to_pathfollow(path)
	path.play()
	trail_particles.attach_to_pathfollow(path)
	
		
# SOUND
	
func _init_sounds() -> void:
	newBottleSoundEvent = FmodServer.create_event_instance("event:/Bottle")
	emptyBottleSoundEvent = FmodServer.create_event_instance("event:/EmptyBottle")
	boatCrashSoundEvent = FmodServer.create_event_instance("event:/BoatCrash")
	boatRepairedSoundEvent = FmodServer.create_event_instance("event:/BoatRepaired")
	
	musicEvent = FmodServer.create_event_instance("event:/Music")
	musicEvent.start()
	
func _update_music(level: float) -> void:
	musicEvent.set_parameter_by_name('Level', level)

func _update_bottle_sound(start: bool) -> void:
	if (start) :
		newBottleSoundEvent.start()
	else:
		emptyBottleSoundEvent.start()
		
func _update_boat_health_sound(up: bool) -> void:
	if (up):
		boatRepairedSoundEvent.start()
	else:
		boatCrashSoundEvent.start()
