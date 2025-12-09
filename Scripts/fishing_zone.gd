extends Area2D
class_name FishingZone

@onready var _exclamation: Node2D = $Exclamation
@export var fishing_scene: PackedScene

var _is_boat_inside := false
var _is_fishing_game_running := false

var boat: Boat

func _process(delta: float) -> void:
	if !_is_boat_inside or _is_fishing_game_running: return
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
		_exclamation.visible = true
		_is_boat_inside = true


func _on_body_exited(body:Node2D) -> void:
	if body.name == "Boat": 
		boat = null
		_exclamation.visible = false
		_is_boat_inside = true
