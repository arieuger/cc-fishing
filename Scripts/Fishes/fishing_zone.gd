extends Area2D
class_name FishingZone

signal zone_exiting

@onready var _exclamation: Node2D = $Exclamation
@export var fishing_scene: PackedScene

var _is_boat_inside := false
var _is_fishing_game_running := false

var alertSoundEvent: FmodEvent = null

func _ready() -> void:
	_init_sounds()

func _process(_delta: float) -> void:
	if !_is_boat_inside or _is_fishing_game_running: return
	if Input.is_action_just_pressed("ui_accept"):
		_is_fishing_game_running = true
		GameManager.boat.fishing = true
		_exclamation.visible = false
		
		var selected_fish: FishData = GameManager.get_random_for_level()		
		var fish_game := fishing_scene.instantiate() as FishingGame
		fish_game.fish_data = selected_fish
		fish_game.fishing_zone = self
		var ui_layer := get_node("/root/MainScene/UILayer")
		var screen_pos: Vector2 = _exclamation.get_global_transform_with_canvas().origin
		fish_game.position = screen_pos
		ui_layer.add_child(fish_game)
	

func _on_body_entered(body:Node2D) -> void:
	if body.name == "Boat":
		_is_boat_inside = true
		_exclamation.visible = true
		_update_sounds(true)

func _on_body_exited(body:Node2D) -> void:
	if body.name == "Boat":
		_is_boat_inside = false
		_exclamation.visible = false
		
func _on_tree_exiting() -> void:
	GameManager.spawn_zones[GameManager.zone_level].connect_zone_signal(self)
	zone_exiting.emit()

# SOUND
	
func _init_sounds() -> void:
	alertSoundEvent = FmodServer.create_event_instance("event:/Alert")
	
func _update_sounds(start: bool) -> void:
	if (start):
		alertSoundEvent.start()
