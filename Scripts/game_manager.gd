extends Node

@export var fish_database: FishDatabase

var zone_level := 0
var player_life := 3
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
		
