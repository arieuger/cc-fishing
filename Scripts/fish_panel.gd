extends Panel

var clickSoundEvent: FmodEvent = null

func _on_ready() -> void:
	_init_sounds()

func _on_close_btn_pressed() -> void:
	find_child("BottleFound").visible = false
	find_child("HeartFound").visible = false
	_update_sounds(true)
	visible = false
	GameManager.boat.showing_ui = false

func _on_mouse_entered() -> void:
	_update_sounds(true)

# SOUND

func _init_sounds() -> void:
	clickSoundEvent = FmodServer.create_event_instance("event:/Click")	
	
func _update_sounds(start: bool) -> void:
	if start:
		clickSoundEvent.start()
