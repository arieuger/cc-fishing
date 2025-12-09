extends Area2D
class_name FishingZone

signal zone_exiting

@onready var _exclamation: Node2D = $Exclamation
@export var fishing_scene: PackedScene

var _is_boat_inside := false
var _is_fishing_game_running := false

var boat: Boat

func _process(_delta: float) -> void:
	if boat == null or !_is_boat_inside or _is_fishing_game_running: return
	if Input.is_action_just_pressed("ui_accept"):
		_is_fishing_game_running = true
		boat.fishing = true
		_exclamation.visible = false
		
		var fish_game := fishing_scene.instantiate() as FishingGame
		fish_game.difficulty = 0.5
		fish_game.fishing_zone = self
		var ui_layer := get_node("/root/MainScene/UILayer")
		ui_layer.add_child(fish_game)
		var screen_pos: Vector2 = _exclamation.get_global_transform_with_canvas().origin
		fish_game.position = screen_pos
		add_child(fish_game)
	

func _on_body_entered(body:Node2D) -> void:
	if body.name == "Boat": 
		boat = body as Boat
		_is_boat_inside = true
		_exclamation.visible = true

func _on_body_exited(body:Node2D) -> void:
	if body.name == "Boat":
		_is_boat_inside = false 
		boat = null
		_exclamation.visible = false
		
func _on_tree_exiting() -> void:
	zone_exiting.emit()
