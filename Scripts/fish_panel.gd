extends Panel

@export_file("*.tscn") var game_scene_path: String = "res://Scenes/end_game.tscn"
var clickSoundEvent: FmodEvent = null

func _on_ready() -> void:
	_init_sounds()

func _on_close_btn_pressed() -> void:
	find_child("BottleFound").visible = false
	find_child("HeartFound").visible = false
	_update_sounds(true)
	visible = false
	GameManager.boat.showing_ui = false
	if GameManager.fishes_catched_by_level == 10:
		GameManager.show_drink_advice()
	if GameManager.zone_level == 2 and GameManager.fishes_catched_by_level == 10:
		if is_instance_valid(GameManager.boat): GameManager.boat.is_dead = true
		get_tree().change_scene_to_file(game_scene_path)

func _on_mouse_entered() -> void:
	_update_sounds(true)

# SOUND

func _init_sounds() -> void:
	clickSoundEvent = FmodServer.create_event_instance("event:/Click")	
	
func _update_sounds(start: bool) -> void:
	if start:
		clickSoundEvent.start()
