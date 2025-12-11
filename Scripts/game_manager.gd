extends Node

@onready var hearts_panel: BoxContainer = $/root/MainScene/UILayer/FullHearts
@onready var bottle_ui: TextureRect = $/root/MainScene/UILayer/FullBottle
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

var newBottleSoundEvent: FmodEvent = null
var emptyBottleSoundEvent: FmodEvent = null
var boatCrashSoundEvent: FmodEvent = null

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
			
func can_receive_bottle() -> bool:
	return not received_bottle_in_level and fishes_catched_by_level >= minimum_fishes_to_bottle[zone_level]
	
func receive_bottle() -> void:
	has_bottle = true
	received_bottle_in_level = true
	bottle_ui.visible = true
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
		hearts_panel.get_children()[player_life - 1].visible = false 
		_update_boat_crash_sound(true)
		
	# TODO: Condicón de morte, gañar vida
		
# SOUND
	
func _init_sounds() -> void:
	newBottleSoundEvent = FmodServer.create_event_instance("event:/Bottle")
	emptyBottleSoundEvent = FmodServer.create_event_instance("event:/EmptyBottle")
	boatCrashSoundEvent = FmodServer.create_event_instance("event:/BoatCrash")
	
func _update_bottle_sound(start: bool) -> void:
	if (start) :
		newBottleSoundEvent.start()
	else:
		emptyBottleSoundEvent.start()
		
func _update_boat_crash_sound(start: bool) -> void:
	if (start):
		boatCrashSoundEvent.start()
