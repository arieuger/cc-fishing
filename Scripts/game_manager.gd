extends Node

@onready var hearts_panel: BoxContainer = $/root/MainScene/UILayer/FullHearts

@export var fish_database: FishDatabase

var zone_level := 0
var player_life := 4
var spawn_zones: Dictionary[int, FishSpawner] = {}
var boat: Boat

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
		print(hearts_panel.get_children().size())
		hearts_panel.get_children()[player_life - 1].visible = false 
		
	# TODO: Condicón de morte, gañar vida
		
