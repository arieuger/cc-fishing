extends PathFollow2D
class_name SeaTrailFollow

@export var speed := 1.2
var playing := false

func _ready() -> void:
	GameManager.trails.append(self)

func play():
	playing = true
	progress_ratio = 0.0

func _process(delta: float) -> void:
	if not playing:
		return

	progress_ratio += speed * delta
	if progress_ratio >= 1.0:
		playing = false