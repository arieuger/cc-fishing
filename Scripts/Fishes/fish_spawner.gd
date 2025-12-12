extends Area2D
class_name FishSpawner

@export var level := 0
@export var fishing_zone_scene: PackedScene
@onready var _col_shape: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	GameManager.spawn_zones[level] = self
	if level == GameManager.zone_level: call_deferred("spawn_fish")

func spawn_fish():
	var zone: FishingZone = fishing_zone_scene.instantiate()
	add_child(zone)
	zone.global_position = _get_valid_spawn_point()
	
func destroy_fishes() -> bool:
	for child in get_children():
		if child is FishingZone:
			child.queue_free()
			return true
	return false

	
func connect_zone_signal(zone: FishingZone):
	zone.zone_exiting.connect(_on_zone_exiting)
	
func _on_zone_exiting() -> void:
	if level != GameManager.zone_level: return
	var wait_time := randf_range(1,3)
	get_tree().create_timer(wait_time).timeout.connect(func(): spawn_fish())
	
func _get_valid_spawn_point() -> Vector2:
	const MAX_ATTEMPTS := 16
	for i in MAX_ATTEMPTS:
		var p := _get_random_point() 
		if not _point_hits_rock(p):
			return p
	return _get_random_point()
	
func _get_random_point() -> Vector2:
	var poly: PackedVector2Array = _col_shape.polygon
	var local_point := _random_point_in_polygon(poly)
	return _col_shape.to_global(local_point)	
	
func _random_point_in_polygon(poly: PackedVector2Array) -> Vector2:
	var index := Geometry2D.triangulate_polygon(poly)
	var tri_list: Array = []
	var areas: Array[float] = []
	var total_area := 0.0

	for i in range(0, index.size(), 3):
		var a := poly[index[i]]
		var b := poly[index[i + 1]]
		var c := poly[index[i + 2]]
		var area: float = abs((b - a).cross(c  - a)) * 0.5
		if area <= 0.0:
			continue
		tri_list.append([a, b, c])
		areas.append(area)
		total_area += area

	var pick := randf() * total_area
	var acc := 0.0
	var tri: Array = tri_list[0]

	for i in areas.size():
		acc += areas[i]
		if pick <= acc:
			tri = tri_list[i]
			break
			
	return _random_point_in_triangle(tri[0], tri[1], tri[2])
	
func _random_point_in_triangle(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	var r1 := sqrt(randf())
	var r2 := randf()
	return (1.0 - r1) * a + r1 * (1.0 - r2) * b + r1 * r2 * c
	
func _point_hits_rock(world_point: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state

	var params := PhysicsPointQueryParameters2D.new()
	params.position = world_point
	params.collide_with_bodies = true
	params.collide_with_areas = true 
	var results := space_state.intersect_point(params, 8)

	for r in results:
		var collider = r["collider"]
		if collider is Node and (collider as Node).is_in_group("damage_zone"):
			return true

	return false
