extends StaticBody2D

@export var level := 0

func _ready() -> void:
	GameManager.buoys[level] = self