extends Node2D
func _ready() -> void:
	GameManager.bind_game_scene(self)
	GameManager.start_game()