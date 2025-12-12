extends Node

@export var fish_database: FishDatabase
@export var minimum_fishes_to_bottle: Dictionary[int, int]
@export var drunk_amount_by_level: Dictionary[int, float] = {}

@export_file("*.tscn") var game_scene_path: String = "res://Scenes/end_game.tscn"

var hearts_panel: BoxContainer
var bottle_ui: TextureRect
var fish_ui_panel: Panel
var fishes_catched_counter: RichTextLabel
var messages: RichTextLabel
var musicEmitter: FmodEventEmitter2D

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
var _level_colors := [
	"#43ba85",
	"#c2b661",
	"#d65e5e"
]
var _lose_fish_messages := [
	"¡Mala mar te coma! Escapou",
	"Xa se sabe: moito peixe rompe a rede"
]

var _lose_life_messages := [
	"Batín cun con. Maldición! ",
	"Á lancha rota calquera vento lle vén en contra…"
]

var _win_bottle_messages := [
	"Un gotiño de augardente fai o home forte e valente (e deixa o estómago quente).",
	"Xa se sabe que augardente e viño poñen o vello mociño.",
	"A quen non quere viño, sete cuncas!",
	"Beber, beber, ata máis non poder.",
	"Allo crúo e viño puro pasan o porto seguro.",
	"Xa se sabe o que din: Deixa o mar onde está; lávate en augardente que millor será",
]

var musicEvent: FmodEvent = null
var newBottleSoundEvent: FmodEvent = null
var emptyBottleSoundEvent: FmodEvent = null
var boatCrashSoundEvent: FmodEvent = null
var boatRepairedSoundEvent: FmodEvent = null

func bind_game_scene(main_scene: Node) -> void:
	hearts_panel = main_scene.get_node("UILayer/FullHearts")
	bottle_ui = main_scene.get_node("UILayer/FullBottle")
	fish_ui_panel = main_scene.get_node("UILayer/FishPanel")
	fishes_catched_counter = main_scene.get_node("UILayer/FishesCounter")
	messages = main_scene.get_node("UILayer/Messages")
	musicEmitter = main_scene.get_node("World/PlayZone/Island/Music")	
	
func start_game() -> void:
	fishes_catched_counter.text = "[color=%s]%s/10[/color]" % [_level_colors[zone_level], 0]
	_init_sounds()


func _process(delta: float) -> void:
	if has_bottle and Input.is_action_just_pressed("drink"):
		has_bottle = false
		bottle_ui.visible = false
		_update_bottle_sound(false)
		buoys[zone_level].queue_free()
		zone_level += 1
		received_bottle_in_level = false
		fishes_catched_by_level = 0
		boat.drunk_amount = drunk_amount_by_level[zone_level]
		fishes_catched_counter.text = "[color=%s]%s/10[/color]" % [_level_colors[zone_level], fishes_catched_by_level]
		# if not spawn_zones[zone_level - 1].destroy_fishes():
		# 	spawn_zones[zone_level].spawn_fish()
		_update_music(zone_level)
		
func catch_fish(fish_data: FishData):
	boat.showing_ui = true
	fishes_catched_by_level += 1
	fishes_catched_counter.text = "[color=%s]%s/10[/color]" % [_level_colors[zone_level], fishes_catched_by_level]
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
		
func lose_fish() -> void:
	messages.visible = true
	messages.text = "[color=#d65e5e]%s[/color]" % [_lose_fish_messages[randi() % _lose_fish_messages.size()]]
	get_tree().create_timer(4.0).timeout.connect(func(): messages.visible = false)
	
func can_receive_bottle() -> bool:
	return zone_level < 2 and not received_bottle_in_level \
	and fishes_catched_by_level >= minimum_fishes_to_bottle[zone_level]
	
func receive_bottle() -> void:
	has_bottle = true
	received_bottle_in_level = true
	bottle_ui.visible = true
	(fish_ui_panel.find_child("BottleFound")).visible = true
	messages.visible = true
	messages.text = "[color=#43ba85]%s[/color]" % [_win_bottle_messages[randi() % _win_bottle_messages.size()]]
	get_tree().create_timer(4.0).timeout.connect(func(): messages.visible = false)
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
	
func update_life() -> void:
	if player_life > 0:
		player_life -= 1
		var heart := _find_first_visible_heart()
		if heart != null: heart.visible = false 
		if player_life > 1:
			messages.visible = true
			messages.text = "[color=#d65e5e]%s[/color]" % [_lose_life_messages[randi() % _lose_life_messages.size()]]
			get_tree().create_timer(4.0).timeout.connect(func():
				if is_instance_valid(messages):
					messages.visible = false
			)
			
		_update_boat_health_sound(false)

	if player_life == 0:
		if is_instance_valid(boat): boat.is_dead = true
		get_tree().change_scene_to_file(game_scene_path)
		
func reset(full: bool = true) -> void:
	zone_level = 0
	player_life = 4
	has_bottle = false
	received_bottle_in_level = false
	fishes_catched_by_level = 0

	spawn_zones.clear()
	trails.clear()

	for k in buoys.keys():
		var b := buoys[k]
		if is_instance_valid(b):
			b.queue_free()
	buoys.clear()

	trail_particles = null
	boat = null

	if is_instance_valid(messages):
		messages.visible = false
	if is_instance_valid(fish_ui_panel):
		fish_ui_panel.visible = false
	if is_instance_valid(bottle_ui):
		bottle_ui.visible = false
	if is_instance_valid(hearts_panel):
		for h in hearts_panel.get_children():
			h.visible = true

	if is_instance_valid(fishes_catched_counter):
		fishes_catched_counter.text = "[color=%s]%s/10[/color]" % [_level_colors[zone_level], 0]

	if full and fish_database:
		for f in fish_database.fishes:
			f.used = false

	if musicEvent != null:
		musicEvent.release()
		musicEvent = null

	for ev in [newBottleSoundEvent, emptyBottleSoundEvent, boatCrashSoundEvent, boatRepairedSoundEvent]:
		if ev != null:
			ev.release()

	newBottleSoundEvent = null
	emptyBottleSoundEvent = null
	boatCrashSoundEvent = null
	boatRepairedSoundEvent = null

	hearts_panel = null
	bottle_ui = null
	fish_ui_panel = null
	fishes_catched_counter = null
	messages = null
	musicEmitter = null
	
func _find_first_visible_heart(visible := true) -> Node:
	for h in hearts_panel.get_children():
		if h.visible == visible: return h
	return null

func _on_trail_timer_timeout() -> void:
	if trails.is_empty() or not is_instance_valid(trail_particles): return
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
	
func _update_music(level: float) -> void:
	musicEmitter.set_parameter('Level', level)

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
