extends GPUParticles2D
class_name SeaTrailParticles

var _follow: PathFollow2D = null
var _active := false

func _ready() -> void:
	GameManager.trail_particles = self

func attach_to_pathfollow(f: PathFollow2D) -> void:
	_follow = f
	_active = true
	emitting = true
	restart()

func detach() -> void:
	_active = false
	emitting = false
	_follow = null


func _process(delta: float) -> void:
	if not _active or _follow == null:
		return
	global_position = _follow.global_position