extends Panel



func _on_close_btn_pressed() -> void:
	find_child("BottleFound").visible = false
	find_child("HeartFound").visible = false
	visible = false
	GameManager.boat.showing_ui = false
