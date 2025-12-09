extends Panel



func _on_close_btn_pressed() -> void:
	visible = false
	GameManager.boat.showing_ui = false
