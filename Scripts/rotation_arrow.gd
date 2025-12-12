extends TextureRect

func _ready() -> void:
	pivot_offset = size * 0.5

func _process(delta: float) -> void:
	var boat := GameManager.boat
	if boat == null: return
	rotation = boat.rotation
