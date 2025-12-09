extends Area2D
class_name FishSpawner

@export var fishing_zone_scene: PackedScene
@onready var _col_shape: CollisionPolygon2D = $CollisionPolygon2D

func _ready() -> void:
	call_deferred("spawn_fish")

func spawn_fish():
	var zone: FishingZone = fishing_zone_scene.instantiate()
	zone.zone_exiting.connect(_on_zone_exiting)
	get_parent().add_child(zone)
	zone.global_position = _get_random_point()
	
func _on_zone_exiting() -> void:
	var wait_time := randf_range(1,3)
	await get_tree().create_timer(wait_time).timeout
	spawn_fish()
	
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
			
	return random_point_in_triangle(tri[0], tri[1], tri[2])
	
func random_point_in_triangle(a: Vector2, b: Vector2, c: Vector2) -> Vector2:
	var r1 := sqrt(randf())
	var r2 := randf()
	return (1.0 - r1) * a + r1 * (1.0 - r2) * b + r1 * r2 * c